// import 'package:ella_lyaabdoon/core/services/prayer_widget_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:home_widget/home_widget.dart';
// import 'dart:math';
// // Add this to the TOP of your main.dart, before the main() function

// @pragma('vm:entry-point')
// Future<void> widgetBackgroundCallback(Uri? uri) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   debugPrint('🔔 Widget Background Callback: $uri');

//   if (uri?.host == 'refresh') {
//     debugPrint('🔄 Refreshing widget from background...');

//     try {
//       // Import the service and call it
//       // This will use the actual prayer times calculation
//       await PrayerWidgetService.updateWidget();

//       debugPrint('✅ Widget refreshed via PrayerWidgetService');
//     } catch (e) {
//       debugPrint('❌ Widget refresh error: $e');

//       // Fallback to simple update if service fails
//       await _fallbackWidgetUpdate();
//     }
//   }
// }

// // Fallback method with simple time-based logic
// Future<void> _fallbackWidgetUpdate() async {
//   try {
//     final now = DateTime.now();
//     final hour = now.hour;

//     String period;
//     List<Map<String, String>> rewards;

//     if (hour >= 22 || hour < 4) {
//       period = 'الليل';
//       rewards = [
//         {'t': 'قيام الليل', 'd': 'أفضل الصلاة بعد الفريضة صلاة الليل'},
//         {'t': 'الدعاء في الليل', 'd': 'ينزل ربنا إلى السماء الدنيا'},
//       ];
//     } else if (hour >= 4 && hour < 6) {
//       period = 'الفجر';
//       rewards = [
//         {
//           't': 'صلاة الفجر في جماعة',
//           'd': 'من صلى الفجر في جماعة فكأنما قام الليل كله',
//         },
//         {'t': 'ركعتا الفجر', 'd': 'ركعتا الفجر خير من الدنيا وما فيها'},
//       ];
//     } else if (hour >= 6 && hour < 12) {
//       period = 'الشروق';
//       rewards = [
//         {'t': 'صلاة الضحى', 'd': 'من صلى الضحى اثنتي عشرة ركعة'},
//         {'t': 'الذكر بعد الفجر', 'd': 'من قعد في مصلاه يذكر الله'},
//       ];
//     } else if (hour >= 12 && hour < 15) {
//       period = 'الظهر';
//       rewards = [
//         {'t': 'أربع قبل الظهر', 'd': 'من صلى أربعا قبل الظهر وأربعا بعدها'},
//         {'t': 'الصلاة على وقتها', 'd': 'الصلاة في أول وقتها'},
//       ];
//     } else if (hour >= 15 && hour < 18) {
//       period = 'العصر';
//       rewards = [
//         {'t': 'من صلى العصر', 'd': 'من صلى البردين دخل الجنة'},
//         {'t': 'الذكر بعد العصر', 'd': 'من قال لا إله إلا الله'},
//       ];
//     } else if (hour >= 18 && hour < 19) {
//       period = 'المغرب';
//       rewards = [
//         {'t': 'صلاة المغرب', 'd': 'من صلى البردين دخل الجنة'},
//         {'t': 'الدعاء عند المغرب', 'd': 'للصائم عند فطره دعوة'},
//       ];
//     } else {
//       period = 'العشاء';
//       rewards = [
//         {'t': 'صلاة العشاء', 'd': 'من صلى العشاء في جماعة'},
//         {'t': 'الوتر', 'd': 'الوتر حق على كل مسلم'},
//       ];
//     }

//     final random = now.millisecondsSinceEpoch % rewards.length;
//     final reward = rewards[random];
//     final timeStr =
//         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

//     await HomeWidget.saveWidgetData<String>('current_period', period);
//     await HomeWidget.saveWidgetData<String>('reward_title', reward['t']!);
//     await HomeWidget.saveWidgetData<String>('reward_description', reward['d']!);
//     await HomeWidget.saveWidgetData<String>('update_time', timeStr);

//     await HomeWidget.updateWidget(androidName: 'PrayerRewardWidgetProvider');
//     await HomeWidget.updateWidget(androidName: 'HomeWidgetReceiver');

//     debugPrint('✅ Fallback widget update completed');
//   } catch (e) {
//     debugPrint('❌ Fallback update error: $e');
//   }
// }
