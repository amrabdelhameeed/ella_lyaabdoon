import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _channelId = 'ella_lyaabdoon';
  static const String _channelName = 'Ella Lyaabdoon';
  static const String _channelDescription = 'Ella Lyaabdoon Notifications';

  // 🔴 NEW: Callback for when user taps notification
  static Function(String?)? onNotificationTap;

  /* -------------------------------------------------------------------------- */
  /*                               INITIALIZATION                               */
  /* -------------------------------------------------------------------------- */

  static Future<void> initialize() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // Then initialize
    const androidInit = AndroidInitializationSettings('notification_icon');

    const settings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    // 🔴 CRITICAL FIX: Add notification tap handler
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request FCM permissions
    await _messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      announcement: true,
      providesAppNotificationSettings: true,
      provisional: true,
      criticalAlert: true,
    );

    // Request Android notification permissions (Android 13+)
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /* -------------------------------------------------------------------------- */
  /*                    NOTIFICATION TAP HANDLER WITH ANALYTICS                 */
  /* -------------------------------------------------------------------------- */

  // 🔴 NEW: Handle notification tap with Firebase Analytics
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped!');
    debugPrint('📱 Payload: ${response.payload}');

    // Parse payload
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final payload = jsonDecode(response.payload!);
        final notificationType = payload['type'] ?? 'unknown';

        // Log to Firebase Analytics
        _logEvent(
          'notification_opened',
          parameters: {
            'notification_type': notificationType,
            'action': response.actionId ?? 'tap',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // Log specific analytics for strike notifications
        if (notificationType == 'strike_warning') {
          final strikeCount = payload['strike_count'] ?? 0;
          _logEvent(
            'strike_notification_opened',
            parameters: {
              'strike_count': strikeCount,
              'scheduled_date': payload['scheduled_date'] ?? '',
            },
          );
        }

        debugPrint('✅ Analytics logged for: $notificationType');
      } catch (e) {
        debugPrint('⚠️ Failed to parse notification payload: $e');
      }
    }

    // Call external callback if set
    onNotificationTap?.call(response.payload);
  }

  /// Log Firebase Analytics events
  static void _logEvent(String eventName, {Map<String, Object>? parameters}) {
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } else {
      debugPrint('📊 [DEBUG] Analytics: $eventName | $parameters');
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                         FCM BACKGROUND HANDLER                              */
  /* -------------------------------------------------------------------------- */

  @pragma('vm:entry-point')
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    debugPrint('📬 Background message received: ${message.messageId}');

    // ✅ IMPORTANT: Initialize in background isolate
    await initialize();

    // Show notification with image
    await _showNotificationWithImage(message);

    // Log FCM notification received
    _logEvent(
      'fcm_notification_received_background',
      parameters: {
        'message_id': message.messageId ?? 'unknown',
        'has_notification': message.notification != null,
        'has_data': message.data.isNotEmpty,
      },
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                         FCM FOREGROUND HANDLER                             */
  /* -------------------------------------------------------------------------- */

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    // Only show if there is a notification object (title/body)
    if (message.notification != null) {
      await _showNotificationWithImage(message);
    }

    // Log FCM notification received
    _logEvent(
      'fcm_notification_received_foreground',
      parameters: {
        'message_id': message.messageId ?? 'unknown',
        'has_notification': message.notification != null,
        'has_data': message.data.isNotEmpty,
      },
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                    SHOW NOTIFICATION WITH IMAGE SUPPORT                    */
  /* -------------------------------------------------------------------------- */

  static Future<void> _showNotificationWithImage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'New Notification';
    final body = message.notification?.body ?? 'You have a new message';

    // Try to get image from notification or data
    final imageUrl =
        message.notification?.android?.imageUrl ?? message.data['image'];

    BigPictureStyleInformation? bigPictureStyleInformation;

    // ✅ Download and process image if available (with better error handling)
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(imageUrl))
            .timeout(
              const Duration(seconds: 120), // Add timeout for release mode
            );

        if (response.statusCode == 200) {
          final byteArray = response.bodyBytes;
          bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(byteArray),
            largeIcon: ByteArrayAndroidBitmap(byteArray),
            contentTitle: title,
            summaryText: body,
            // htmlFormatContentTitle: true,
            // htmlFormatSummaryText: true,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Failed to fetch notification image: $e');
        // Continue without image
      }
    }

    // Add notification type to payload
    final payload = Map<String, dynamic>.from(message.data);
    if (!payload.containsKey('type')) {
      payload['type'] = 'fcm_notification';
    }

    // Show notification
    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          color: const Color.fromARGB(255, 15, 170, 70),
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
          colorized: true,
          styleInformation:
              bigPictureStyleInformation ??
              (body.length > 50 ? BigTextStyleInformation(body) : null),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload.isEmpty ? null : jsonEncode(payload),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                            SHOW LOCAL (NOW, SCHEDULED, Daily)              */
  /* -------------------------------------------------------------------------- */

  static Future<void> showNow({
    required int notificationId,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _local.show(
      notificationId,
      title,
      body,
      _details(bigText: body),
      payload: payload == null ? null : jsonEncode(payload),
    );

    _logEvent(
      'local_notification_shown',
      parameters: {
        'notification_id': notificationId,
        'type': payload?['type'] ?? 'unknown',
      },
    );
  }

  static Future<void> scheduleAt({
    required int notificationId,
    required String title,
    required String body,
    required DateTime dateTime,
    Map<String, dynamic>? payload,
  }) async {
    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    await _local.zonedSchedule(
      notificationId,
      title,
      body,
      tzDate,
      _details(bigText: body),
      payload: payload == null ? null : jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('✅ Notification scheduled for: ${dateTime.toString()}');
  }

  static Future<void> scheduleDaily({
    required int notificationId,
    required String title,
    required String body,
    required TimeOfDay time,
    Map<String, dynamic>? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _local.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      _details(bigText: body),
      payload: payload == null ? null : jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                    GET PENDING/SCHEDULED NOTIFICATIONS                     */
  /* -------------------------------------------------------------------------- */

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _local.pendingNotificationRequests();
  }

  static Future<int> getPendingNotificationCount() async {
    final pending = await _local.pendingNotificationRequests();
    return pending.length;
  }

  static Future<bool> isNotificationScheduled(int id) async {
    final pending = await _local.pendingNotificationRequests();
    return pending.any((notification) => notification.id == id);
  }

  /* -------------------------------------------------------------------------- */
  /*                                TOPICS                                      */
  /* -------------------------------------------------------------------------- */

  static Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  static Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  /* -------------------------------------------------------------------------- */
  /*                                HELPERS                                     */
  /* -------------------------------------------------------------------------- */

  static NotificationDetails _details({String? bigText}) {
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      color: const Color.fromARGB(255, 15, 170, 70),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      colorized: true,
      styleInformation: bigText != null
          ? BigTextStyleInformation(
              bigText,
              contentTitle: null,
              summaryText: null,
            )
          : null,
    );

    return NotificationDetails(android: android);
  }

  static Future<void> cancel(int id) => _local.cancel(id);

  static Future<void> cancelAll() => _local.cancelAll();
}
