import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StrikeService {
  static const String _lastOpenKey = 'lastOpenDate';
  static const String _strikeCountKey = 'strikeCount';
  static const String _lastNotificationScheduledKey =
      'lastNotificationScheduled';
  static const int notificationId = 9999;

  static Color getStrikeColor(int count) {
    if (count <= 0) return Colors.grey;
    if (count < 3) return const Color(0xffF45D51);
    if (count < 7) return Colors.orange;
    if (count < 14) return Colors.deepOrange;
    if (count < 30) return Colors.amber;
    return Colors.purple;
  }

  /// Get current date without time component
  static DateTime _getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Log Firebase Analytics events
  static void _logEvent(String eventName, {Map<String, Object>? parameters}) {
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );
    }
  }

  static Future<void> handleAppOpen() async {
    debugPrint('🚀 handleAppOpen called');
    final now = DateTime.now();
    final todayDateOnly = _getDateOnly(now);

    final lastOpenStr = CacheHelper.getString(_lastOpenKey);
    int currentStrikeCount = CacheHelper.getInt(_strikeCountKey);

    debugPrint('📅 Today: ${DateFormat("yyyy-MM-dd").format(todayDateOnly)}');
    debugPrint('💾 Last open stored: $lastOpenStr');
    debugPrint('🔥 Current strike count: $currentStrikeCount');

    // First time user or new strike calculation
    if (lastOpenStr.isEmpty) {
      await _handleFirstTimeOpen(now, todayDateOnly);
      return;
    }

    // Parse last open date
    final lastOpen = DateTime.parse(lastOpenStr);
    final lastOpenDateOnly = _getDateOnly(lastOpen);

    debugPrint(
      '📆 Last open date: ${DateFormat("yyyy-MM-dd").format(lastOpenDateOnly)}',
    );

    // Calculate difference in days
    final daysDifference = todayDateOnly.difference(lastOpenDateOnly).inDays;
    debugPrint('📊 Days difference: $daysDifference');

    if (daysDifference == 0) {
      // Same day - just update timestamp but DON'T cancel notification
      await _handleSameDayOpen(now, todayDateOnly);
    } else if (daysDifference == 1) {
      // Consecutive day - increment strike
      await _handleConsecutiveDayOpen(now, todayDateOnly, currentStrikeCount);
    } else if (daysDifference > 1) {
      // Missed days - reset strike
      await _handleMissedDaysOpen(now, todayDateOnly, daysDifference);
    } else {
      // Negative difference (clock changed or timezone issue)
      debugPrint(
        '⚠️ Warning: Negative day difference detected. Treating as same day.',
      );
      await _handleSameDayOpen(now, todayDateOnly);
    }
  }

  static Future<void> _handleFirstTimeOpen(
    DateTime now,
    DateTime todayDateOnly,
  ) async {
    debugPrint('🎉 First time opening app - Setting strike to 1');

    CacheHelper.setString(_lastOpenKey, now.toIso8601String());
    CacheHelper.setInt(_strikeCountKey, 1);

    _logEvent(
      'strike_started',
      parameters: {
        'strike_count': 1,
        'date': DateFormat('yyyy-MM-dd').format(todayDateOnly),
      },
    );

    // Schedule reminder for tomorrow
    await _scheduleStrikeWarning(todayDateOnly);
  }

  // 🔴 CRITICAL FIX #1: Same day open should NOT cancel notification
  // Users open the app multiple times per day, canceling prevents future notifications
  static Future<void> _handleSameDayOpen(
    DateTime now,
    DateTime todayDateOnly,
  ) async {
    debugPrint('✅ Same day open - Updating timestamp only');

    // Update the timestamp to latest open time
    CacheHelper.setString(_lastOpenKey, now.toIso8601String());

    // 🔴 REMOVED: Don't cancel notification on same-day opens
    // The notification is for TOMORROW, not today
    // await NotificationHelper.cancel(notificationId); // ❌ BAD

    // 🔴 CRITICAL FIX #2: Ensure notification is still scheduled for tomorrow
    await _ensureNotificationScheduled(todayDateOnly);
  }

  static Future<void> _handleConsecutiveDayOpen(
    DateTime now,
    DateTime todayDateOnly,
    int currentStrikeCount,
  ) async {
    final newStrikeCount = currentStrikeCount + 1;
    debugPrint(
      '🔥 Consecutive day! Strike: $currentStrikeCount → $newStrikeCount',
    );

    CacheHelper.setString(_lastOpenKey, now.toIso8601String());
    CacheHelper.setInt(_strikeCountKey, newStrikeCount);

    _logEvent(
      'strike_continued',
      parameters: {
        'previous_count': currentStrikeCount,
        'new_count': newStrikeCount,
        'date': DateFormat('yyyy-MM-dd').format(todayDateOnly),
      },
    );

    // Schedule new notification for tomorrow
    await _scheduleStrikeWarning(todayDateOnly);
  }

  static Future<void> _handleMissedDaysOpen(
    DateTime now,
    DateTime todayDateOnly,
    int daysDifference,
  ) async {
    final previousStrike = CacheHelper.getInt(_strikeCountKey);

    debugPrint(
      '💔 Missed ${daysDifference - 1} day(s) - Resetting strike to 1',
    );

    CacheHelper.setString(_lastOpenKey, now.toIso8601String());
    CacheHelper.setInt(_strikeCountKey, 1);

    _logEvent(
      'strike_broken',
      parameters: {
        'previous_count': previousStrike,
        'days_missed': daysDifference - 1,
        'date': DateFormat('yyyy-MM-dd').format(todayDateOnly),
      },
    );

    // Cancel old notification and schedule new one
    await NotificationHelper.cancel(notificationId);
    await _scheduleStrikeWarning(todayDateOnly);
  }

  // 🔴 CRITICAL FIX #3: New method to ensure notification is always scheduled
  static Future<void> _ensureNotificationScheduled(
    DateTime todayDateOnly,
  ) async {
    final strikeCount = CacheHelper.getInt(_strikeCountKey);

    if (strikeCount <= 0) {
      debugPrint('⏰ No active strike - notification NOT needed');
      return;
    }

    // Check if notification is already scheduled for tomorrow
    final isScheduled = await NotificationHelper.isNotificationScheduled(
      notificationId,
    );

    if (!isScheduled) {
      debugPrint('⚠️ Notification missing! Rescheduling...');
      await _scheduleStrikeWarning(todayDateOnly);
    } else {
      debugPrint('✅ Notification already scheduled for tomorrow');
    }
  }

  // 🔴 CRITICAL FIX #4: Removed duplicate scheduling prevention logic
  // The old logic prevented notifications from being rescheduled properly
  static Future<void> _scheduleStrikeWarning(DateTime todayDateOnly) async {
    final strikeCount = CacheHelper.getInt(_strikeCountKey);

    if (strikeCount <= 0) {
      debugPrint('⏰ No active strike - notification NOT scheduled');
      return;
    }

    // Cancel any existing notification first
    await NotificationHelper.cancel(notificationId);

    // Schedule for tomorrow at 22:00 (10:00 PM)
    final tomorrow = !kDebugMode
        ? DateTime(
            todayDateOnly.year,
            todayDateOnly.month,
            todayDateOnly.day + 1,
            22,
            0,
          )
        : DateTime.now().add(const Duration(minutes: 1));

    String title = "strike_reminder_title".tr();
    String body = "strike_reminder_body".tr();

    // Fallback for uninitialized translations
    if (title == "strike_reminder_title") {
      title = "حافظ على تتابع أيامك! 🔥";
      body =
          "أنت على وشك فقدان تتابع أيامك في ذكر الله. افتح التطبيق الآن لتحافظ عليه!";
    }

    await NotificationHelper.scheduleAt(
      notificationId: notificationId,
      title: title,
      body: body,
      dateTime: tomorrow,
      payload: {
        'type': 'strike_warning',
        'strike_count': strikeCount,
        'scheduled_date': tomorrow.toIso8601String(),
      },
    );

    // Save when we scheduled this notification
    CacheHelper.setString(
      _lastNotificationScheduledKey,
      tomorrow.toIso8601String(),
    );

    debugPrint(
      '⏰ Reminder scheduled for: ${DateFormat("yyyy-MM-dd hh:mm a").format(tomorrow)} | Strike: $strikeCount',
    );

    _logEvent(
      'strike_notification_scheduled',
      parameters: {
        'strike_count': strikeCount,
        'scheduled_time': tomorrow.toIso8601String(),
      },
    );
  }

  static int getStrikeCount() {
    return CacheHelper.getInt(_strikeCountKey);
  }

  /// Check if user's strike is in danger (didn't open today yet)
  static bool isStrikeInDanger() {
    final lastOpenStr = CacheHelper.getString(_lastOpenKey);
    if (lastOpenStr.isEmpty) return false;

    final strikeCount = CacheHelper.getInt(_strikeCountKey);
    if (strikeCount <= 0) return false;

    final lastOpen = DateTime.parse(lastOpenStr);
    final lastOpenDateOnly = _getDateOnly(lastOpen);
    final todayDateOnly = _getDateOnly(DateTime.now());

    final daysDifference = todayDateOnly.difference(lastOpenDateOnly).inDays;

    return daysDifference >= 1;
  }

  /// Reset strike manually
  static Future<void> resetStrike() async {
    final previousStrike = CacheHelper.getInt(_strikeCountKey);

    debugPrint('🔄 Strike reset manually');

    CacheHelper.setInt(_strikeCountKey, 0);
    CacheHelper.remove(_lastOpenKey);
    CacheHelper.remove(_lastNotificationScheduledKey);
    await NotificationHelper.cancel(notificationId);

    _logEvent(
      'strike_reset_manual',
      parameters: {'previous_count': previousStrike},
    );
  }

  /// Get strike status information
  static Map<String, dynamic> getStrikeStatus() {
    final lastOpenStr = CacheHelper.getString(_lastOpenKey);
    final strikeCount = CacheHelper.getInt(_strikeCountKey);

    if (lastOpenStr.isEmpty) {
      return {
        'strikeCount': 0,
        'isActive': false,
        'lastOpen': null,
        'isInDanger': false,
      };
    }

    final lastOpen = DateTime.parse(lastOpenStr);
    final lastOpenDateOnly = _getDateOnly(lastOpen);
    final todayDateOnly = _getDateOnly(DateTime.now());
    final daysDifference = todayDateOnly.difference(lastOpenDateOnly).inDays;

    return {
      'strikeCount': strikeCount,
      'isActive': strikeCount > 0,
      'lastOpen': lastOpen,
      'daysSinceLastOpen': daysDifference,
      'isInDanger': daysDifference >= 1 && strikeCount > 0,
      'openedToday': daysDifference == 0,
    };
  }
}
