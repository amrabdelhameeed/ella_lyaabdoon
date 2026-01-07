import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final messaging = FirebaseMessaging.instance;
  static bool _isFullyInitialized = false;

  // Call this in main() - only basic setup, no navigation handling
  static Future<void> initializeBasic() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon_adaptive_fore');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification: Permission granted');
    } else {
      debugPrint('Notification: Permission denied');
    }

    // When the app is in foreground - only show notifications, no navigation yet
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Notification: onMessage received');
      await handleNotification(message.toMap());
    });
  }

  static Map<String, dynamic> _convertStringToMap(String payloadString) {
    try {
      final decoded = json.decode(payloadString);
      debugPrint('Notification: Successfully decoded payload: $decoded');
      return decoded;
    } catch (e) {
      debugPrint("Notification: Failed to parse payload string: $e");
      return {};
    }
  }

  static Future<void> handleNotification(Map<String, dynamic> message) async {
    final NotificationData data = NotificationData.fromMap(message);
    if (data.title.isNotEmpty && data.body.isNotEmpty) {
      await _showLocalNotification(data);
    }
  }

  static Future<void> _showLocalNotification(NotificationData data) async {
    final int notificationId = Random().nextInt(54552);

    final androidDetails = AndroidNotificationDetails(
      'GuROW',
      'GuROW',
      icon: '@drawable/notification_icon',
      groupKey: "groupKey$notificationId",
      visibility: NotificationVisibility.public,
      groupAlertBehavior: GroupAlertBehavior.all,
      color: Color(0xFF980000),
      colorized: true,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    final String payload = json.encode({
      "id": data.id?.toString() ?? "",
      "type": data.screenName ?? "",
    });

    debugPrint('Notification: Creating notification with payload: $payload');

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      data.title,
      data.body,
      platformDetails,
      payload: payload,
    );
  }

  static Future subscribeToTopic(String topic) async =>
      await messaging.subscribeToTopic(topic);
  static Future unSubscribeToTopic(String topic) async =>
      await messaging.unsubscribeFromTopic(topic);
}

class NotificationData {
  final String title;
  final String body;
  final int? id;
  final String? screenName;

  NotificationData({
    required this.title,
    required this.body,
    this.id,
    this.screenName,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['notification']?['title'] ?? '',
      body: map['notification']?['body'] ?? '',
      id: int.tryParse((map['data']?['id'] ?? "").toString()),
      screenName: map['data']?['type']?.toString(),
    );
  }
}
