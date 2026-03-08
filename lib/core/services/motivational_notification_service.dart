import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:flutter/foundation.dart';

class MotivationalNotificationService {
  MotivationalNotificationService._();

  static const String _lastMotivationalCheckKey = 'last_motivational_check';
  static const String _motivationalEnabledKey =
      'motivational_notifications_enabled';
  static const int _notificationId = 9999;

  /// Check if motivational notifications are enabled
  static bool isEnabled() {
    return CacheHelper.getBool(_motivationalEnabledKey);
  }

  /// Toggle motivational notifications on/off
  static void setEnabled(bool value) {
    CacheHelper.setBool(_motivationalEnabledKey, value);
    if (!value) {
      NotificationHelper.cancel(_notificationId);
    }
  }

  /// Called from app open — checks weekly and schedules a motivational notification
  static Future<void> checkAndSchedule() async {
    if (!isEnabled()) return;

    final lastCheck = CacheHelper.getString(_lastMotivationalCheckKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = today.toIso8601String();

    // Only check once per day
    if (lastCheck == todayStr) return;
    CacheHelper.setString(_lastMotivationalCheckKey, todayStr);

    // Only send on Fridays (day 5) for weekly summary
    if (now.weekday != DateTime.friday) return;

    final message = _generateMotivationalMessage();
    if (message == null) return;

    try {
      // Schedule for 2 hours from now (afternoon on Friday)
      final scheduledTime = now.add(const Duration(hours: 2));
      await NotificationHelper.scheduleAt(
        notificationId: _notificationId,
        title: message['title']!,
        body: message['body']!,
        dateTime: scheduledTime,
      );
      debugPrint('📬 Motivational notification scheduled');
    } catch (e) {
      debugPrint('❌ Failed to schedule motivational notification: $e');
    }
  }

  /// Generate a motivational message based on weekly performance
  static Map<String, String>? _generateMotivationalMessage() {
    final zikrsThisWeek = HistoryDBProvider.getZikrsThisWeek();
    final zikrsLastWeek = HistoryDBProvider.getZikrsLastWeek();
    final opensThisWeek = HistoryDBProvider.getAppOpensThisWeek();
    final opensLastWeek = HistoryDBProvider.getAppOpensLastWeek();

    final zikrDiff = zikrsThisWeek - zikrsLastWeek;
    final opensDiff = opensThisWeek - opensLastWeek;

    String title;
    String body;

    if (zikrDiff > 0 && opensDiff >= 0) {
      // Improved in zikrs
      final percent = zikrsLastWeek > 0
          ? ((zikrDiff / zikrsLastWeek) * 100).round()
          : 100;
      title = 'motivational_improved_title'.tr();
      body = 'motivational_improved_body'.tr(
        namedArgs: {'percent': '$percent', 'count': '$zikrsThisWeek'},
      );
    } else if (zikrDiff == 0 && opensThisWeek > 0) {
      // Same as last week
      title = 'motivational_same_title'.tr();
      body = 'motivational_same_body'.tr(
        namedArgs: {'count': '$zikrsThisWeek'},
      );
    } else if (zikrDiff < 0) {
      // Declined
      title = 'motivational_declined_title'.tr();
      body = 'motivational_declined_body'.tr(
        namedArgs: {'lastWeek': '$zikrsLastWeek', 'thisWeek': '$zikrsThisWeek'},
      );
    } else if (opensThisWeek == 0) {
      // Didn't open at all
      title = 'motivational_inactive_title'.tr();
      body = 'motivational_inactive_body'.tr();
    } else {
      return null;
    }

    return {'title': title, 'body': body};
  }
}
