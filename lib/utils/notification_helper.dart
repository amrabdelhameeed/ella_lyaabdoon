import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String _channelId = 'ella_lyaabdoon';
  static const String _channelName = 'Ella Lyaabdoon';

  /* -------------------------------------------------------------------------- */
  /*                               INITIALIZATION                               */
  /* -------------------------------------------------------------------------- */

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('notification_icon');

    const settings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _local.initialize(settings);

    await _messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      announcement: true,
      providesAppNotificationSettings: true,
      provisional: true,
      criticalAlert: true,
    );
    _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /* -------------------------------------------------------------------------- */
  /*                         FCM BACKGROUND HANDLER                              */
  /* -------------------------------------------------------------------------- */

  @pragma('vm:entry-point')
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    // ⚠️ Do NOT show notification here - FCM handles it automatically
    // This handler is just for processing data or logging
    debugPrint('📬 Background message received: ${message.messageId}');
    // Initialize local notifications if not already
    // await NotificationHelper.initialize();

    // Show notification (supports image)
    await NotificationHelper._showNotificationWithImage(message);
    // You can process data here if needed
    // But don't call _showNotificationWithImage() to avoid duplicates
  }

  /* -------------------------------------------------------------------------- */
  /*                         FCM FOREGROUND HANDLER                             */
  /* -------------------------------------------------------------------------- */

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    // Only show if there is a notification object (title/body)
    if (message.notification != null) {
      await _showNotificationWithImage(message);
    }
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

    // Download and process image if available
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final byteArray = response.bodyBytes;
          bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(byteArray),
            largeIcon: ByteArrayAndroidBitmap(byteArray),
            contentTitle: title,
            summaryText: body,
          );
        }
      } catch (e) {
        debugPrint('Failed to fetch notification image: $e');
      }
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
      payload: message.data.isEmpty ? null : jsonEncode(message.data),
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
    );
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
