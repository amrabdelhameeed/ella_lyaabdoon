// import 'dart:async';
// import 'dart:io';
// import 'dart:math';

// // import 'package:engazi/core/utils/app_database_keys.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationHelper {
//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     tz.initializeTimeZones();
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
//   }

//   static Future<void> showCustomNotification(String title, String body, [String? imagePath, String? soundPath]) async {
//     // flutterLocalNotificationsPlugin.cancelAll();
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       "Engazi",
//       "Engazi",
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       largeIcon: imagePath != null ? FilePathAndroidBitmap(await _copyAssetToFile(imagePath)) : null,
//       styleInformation: imagePath != null ? BigPictureStyleInformation(FilePathAndroidBitmap(await _copyAssetToFile(imagePath))) : null,
//       sound: soundPath != null ? RawResourceAndroidNotificationSound(soundPath.split('.').first) : null,
//     );
//     final platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//     );
//   }

//   static Future<void> scheduleCustomNotification(
//     String title,
//     String body,
//   ) async {
//     tz.initializeTimeZones();
//     // final String timeZoneName = tz.local.name;
//     final id = Random().nextInt(5);
//     final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: Random().nextInt(10) + 1)); // Random().nextInt(10) + 15
//     // final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: Random().nextInt(5))); // Random().nextInt(10) + 15

//     // print("${scheduledTime.toString()}\nid:${id}\n$body");
//     // if (scheduledTime.isBefore(now)) {
//     //   // Add 1 day if scheduled time is in the past
//     //   scheduledTime.add(const Duration(days: 1));
//     // }
//     const androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       "Engazi",
//       "Engazi",
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//     );
//     try {
//       await flutterLocalNotificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           scheduledTime,
//           const NotificationDetails(
//             android: androidPlatformChannelSpecifics,
//           ),
//           uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//           matchDateTimeComponents: DateTimeComponents.time,
//           androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
//       //       await flutterLocalNotificationsPlugin.zonedSchedule(
//       // 0,
//       // title,
//       // body,
//       // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
//       // const NotificationDetails(
//       //     android: AndroidNotificationDetails(
//       //         'your channel id', 'your channel name',
//       //         channelDescription: 'your channel description')),
//       // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       // uiLocalNotificationDateInterpretation:
//       //     UILocalNotificationDateInterpretation.absoluteTime);
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   static Future<String> _copyAssetToFile(String assetPath) async {
//     final appDocDir = await getTemporaryDirectory();
//     final tempFilePath = '${appDocDir.path}/${assetPath.split('/').last}';
//     final byteData = await rootBundle.load(assetPath);
//     final bytes = byteData.buffer.asUint8List();
//     await File(tempFilePath).writeAsBytes(bytes);
//     return tempFilePath;
//   }
// }
