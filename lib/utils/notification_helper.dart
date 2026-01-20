import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;

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

    await _messaging.requestPermission(alert: true, sound: true, badge: true);
    _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // await _local
    //     .resolvePlatformSpecificImplementation<
    //       AndroidFlutterLocalNotificationsPlugin
    //     >()
    //     ?.requestExactAlarmsPermission();
  }

  /* -------------------------------------------------------------------------- */
  /*                         FCM BACKGROUND HANDLER                              */
  /* -------------------------------------------------------------------------- */

  /* -------------------------------------------------------------------------- */
  /*                         FCM BACKGROUND HANDLER                              */
  /* -------------------------------------------------------------------------- */

  @pragma('vm:entry-point')
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    // If you need to access other plugins, you might need to initialize them here
    // But for just showing a notification, direct usage often works if init was done.
    // However, in a background isolate, we usually need re-init.

    // We can reuse the same settings
    const androidInit = AndroidInitializationSettings('notification_icon');
    const settings = InitializationSettings(android: androidInit);

    await _local.initialize(settings);

    // Show the notification
    await _local.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      _details(),
      payload: message.data.isEmpty ? null : jsonEncode(message.data),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                         FCM FOREGROUND HANDLER                             */
  /* -------------------------------------------------------------------------- */

  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    // When app is in foreground, Firebase doesn't show notification automatically
    // We need to show it manually using local notifications

    // Only show if there is a notification object (title/body)
    if (message.notification != null) {
      await _local.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        _details(),
        payload: message.data.isEmpty ? null : jsonEncode(message.data),
      );
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                            SHOW LOCAL (NOW, SCHEDULED, Daily)                                */
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
      _details(bigText: body), // Pass body here
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
      _details(bigText: body), // Pass body here
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
      _details(bigText: body), // Pass body here
      payload: payload == null ? null : jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                    GET PENDING/SCHEDULED NOTIFICATIONS                     */
  /* -------------------------------------------------------------------------- */

  /// Returns all pending scheduled notifications
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _local.pendingNotificationRequests();
  }

  /// Returns count of pending notifications
  static Future<int> getPendingNotificationCount() async {
    final pending = await _local.pendingNotificationRequests();
    return pending.length;
  }

  /// Check if a specific notification ID is scheduled
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
      'ella_lyaabdoon',
      'Ella Lyaabdoon',
      color: const Color.fromARGB(255, 15, 170, 70),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      colorized: true,
      // Add this for expanded text
      styleInformation: bigText != null
          ? BigTextStyleInformation(
              bigText,
              contentTitle: null, // Uses the main title
              summaryText: null,
            )
          : null,
    );

    return NotificationDetails(android: android);
  }

  /// Cancel a specific notification
  static Future<void> cancel(int id) => _local.cancel(id);

  /// Cancel all notifications
  static Future<void> cancelAll() => _local.cancelAll();
}
