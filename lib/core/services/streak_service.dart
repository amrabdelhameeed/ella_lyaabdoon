import 'dart:convert';
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/utils/notification_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StreakService {
  static const String _lastOpenKey = 'lastOpenDate';
  static const String _streakCountKey = 'strikeCount';
  static const String _lastNotificationScheduledKey =
      'lastNotificationScheduled';
  static const int notificationId = 9999;

  // Statistics tracking keys
  static const String _longestStreakKey = 'longestStreak';
  static const String _totalActiveDaysKey = 'totalActiveDays';
  static const String _streakStartDateKey = 'streakStartDate';
  static const String _streakBreakCountKey = 'streakBreakCount';
  static const String _allStreaksKey =
      'allStreaks'; // JSON list of past streaks
  static const String _activeDaysListKey =
      'activeDaysList'; // JSON list of dates
  static const String _achievedMilestonesKey =
      'achievedMilestones'; // JSON list
  static const String _lastCelebrationKey =
      'lastCelebration'; // Prevent duplicate celebrations

  // Migration flag to track if statistics have been initialized
  static const String _statisticsMigratedKey = 'statisticsMigrated_v1';

  // Pending celebration key (for when app opens before HomeScreen is ready)
  static const String _pendingCelebrationKey = 'pendingCelebration';

  // Milestone thresholds
  static const List<int> milestones = [3, 7, 14, 30, 60, 90, 180, 365];
  static const Map<int, String> milestoneNames = {
    3: 'milestone_bronze',
    7: 'milestone_silver',
    14: 'milestone_gold',
    30: 'milestone_platinum',
    60: 'milestone_diamond',
    90: 'milestone_master',
    180: 'milestone_legend',
    365: 'milestone_immortal',
  };

  // Reactive notifiers
  static final ValueNotifier<int> streakNotifier = ValueNotifier(
    CacheHelper.getInt(_streakCountKey),
  );

  static final StreamController<Map<String, dynamic>> _milestoneController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get milestoneStream =>
      _milestoneController.stream;

  static Color getStreakColor(int count) {
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
    int currentstreakCount = CacheHelper.getInt(_streakCountKey);

    debugPrint('📅 Today: ${DateFormat("yyyy-MM-dd").format(todayDateOnly)}');
    debugPrint('💾 Last open stored: $lastOpenStr');
    debugPrint('🔥 Current streak count: $currentstreakCount');

    // First time user or new streak calculation
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
      // Consecutive day - increment streak
      await _handleConsecutiveDayOpen(now, todayDateOnly, currentstreakCount);
    } else if (daysDifference > 1) {
      // Missed days - reset streak
      await _handleMissedDaysOpen(now, todayDateOnly, daysDifference);
    } else {
      // Negative difference (clock changed or timezone issue)
      debugPrint(
        '⚠️ Warning: Negative day difference detected. Treating as same day.',
      );
      await _handleSameDayOpen(now, todayDateOnly);
    }

    // Migrate statistics for existing users (one-time operation)
    _migrateStatisticsIfNeeded(currentstreakCount, lastOpenDateOnly);
  }

  /// One-time migration to initialize statistics for existing users
  static void _migrateStatisticsIfNeeded(
    int currentStreak,
    DateTime lastOpenDate,
  ) {
    // Check if migration already done
    final migrated = CacheHelper.getBool(_statisticsMigratedKey);
    if (migrated) return;

    debugPrint('🔄 Migrating statistics for existing user...');

    try {
      // Initialize longest streak with current streak if not set
      final longestStreak = CacheHelper.getInt(_longestStreakKey);
      if (longestStreak == 0 && currentStreak > 0) {
        CacheHelper.setInt(_longestStreakKey, currentStreak);
        debugPrint('✅ Set longest streak to current: $currentStreak');
      }

      // Initialize total active days with current streak if not set
      final totalActiveDays = CacheHelper.getInt(_totalActiveDaysKey);
      if (totalActiveDays == 0 && currentStreak > 0) {
        CacheHelper.setInt(_totalActiveDaysKey, currentStreak);
        debugPrint('✅ Set total active days to current: $currentStreak');
      }

      // Initialize streak start date if not set
      final streakStartStr = CacheHelper.getString(_streakStartDateKey);
      if (streakStartStr.isEmpty && currentStreak > 0) {
        // Calculate approximate start date based on current streak
        final approximateStartDate = lastOpenDate.subtract(
          Duration(days: currentStreak - 1),
        );
        CacheHelper.setString(
          _streakStartDateKey,
          approximateStartDate.toIso8601String(),
        );
        debugPrint(
          '✅ Set streak start date to: ${DateFormat("yyyy-MM-dd").format(approximateStartDate)}',
        );
      }

      // Initialize active days list with approximate dates
      final activeDaysStr = CacheHelper.getString(_activeDaysListKey);
      if (activeDaysStr.isEmpty && currentStreak > 0) {
        final activeDays = <String>[];
        for (int i = currentStreak - 1; i >= 0; i--) {
          final date = lastOpenDate.subtract(Duration(days: i));
          activeDays.add(date.toIso8601String());
        }
        CacheHelper.setString(_activeDaysListKey, jsonEncode(activeDays));
        debugPrint('✅ Initialized active days list with $currentStreak days');
      }

      // Initialize achieved milestones based on current streak
      final achievedStr = CacheHelper.getString(_achievedMilestonesKey);
      if (achievedStr.isEmpty && currentStreak > 0) {
        final achieved = milestones.where((m) => m <= currentStreak).toList();
        CacheHelper.setString(_achievedMilestonesKey, jsonEncode(achieved));
        debugPrint('✅ Initialized achieved milestones: $achieved');
      }

      // Mark migration as complete
      CacheHelper.setBool(_statisticsMigratedKey, true);
      debugPrint('✅ Statistics migration completed successfully');
    } catch (e) {
      debugPrint('❌ Error during statistics migration: $e');
      // Don't mark as migrated so it can retry next time
    }
  }

  static Future<void> _handleFirstTimeOpen(
    DateTime now,
    DateTime todayDateOnly,
  ) async {
    debugPrint('🎉 First time opening app - Setting streak to 1');

    CacheHelper.setString(_lastOpenKey, now.toIso8601String());
    CacheHelper.setInt(_streakCountKey, 1);

    // Update statistics
    _updateStatistics(1, true);

    _logEvent(
      'streak_started',
      parameters: {
        'streak_count': 1,
        'date': DateFormat('yyyy-MM-dd').format(todayDateOnly),
      },
    );

    // Schedule reminder for tomorrow
    await _scheduleStreakWarning(todayDateOnly);
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
    int currentStreakCount,
  ) async {
    final newStreakCount = currentStreakCount + 1;
    debugPrint(
      '🔥 Consecutive day! Streak: $currentStreakCount → $newStreakCount',
    );

    CacheHelper.setString(_lastOpenKey, now.toIso8601String());
    CacheHelper.setInt(_streakCountKey, newStreakCount);

    // Update notifier
    streakNotifier.value = newStreakCount;

    // Update statistics
    _updateStatistics(newStreakCount, true);

    // Check for milestone achievement
    checkMilestoneAchievement(newStreakCount);

    _logEvent(
      'Streak_continued',
      parameters: {
        'previous_count': currentStreakCount,
        'new_count': newStreakCount,
        'date': DateFormat('yyyy-MM-dd').format(todayDateOnly),
      },
    );

    // Schedule new notification for tomorrow
    await _scheduleStreakWarning(todayDateOnly);
  }

  static Future<void> _handleMissedDaysOpen(
    DateTime now,
    DateTime todayDateOnly,
    int daysDifference,
  ) async {
    final previousStreak = CacheHelper.getInt(_streakCountKey);

    debugPrint(
      '💔 Missed ${daysDifference - 1} day(s) - Resetting Streak to 1',
    );

    // Record the streak break
    _recordStreakBreak(previousStreak);

    CacheHelper.setString(_lastOpenKey, now.toIso8601String());
    CacheHelper.setInt(_streakCountKey, 1);

    // Update notifier
    streakNotifier.value = 1;

    // Update statistics for new streak
    _updateStatistics(1, true);

    _logEvent(
      'Streak_broken',
      parameters: {
        'previous_count': previousStreak,
        'days_missed': daysDifference - 1,
        'date': DateFormat('yyyy-MM-dd').format(todayDateOnly),
      },
    );

    // Cancel old notification and schedule new one
    await NotificationHelper.cancel(notificationId);
    await _scheduleStreakWarning(todayDateOnly);
  }

  // 🔴 CRITICAL FIX #3: New method to ensure notification is always scheduled
  static Future<void> _ensureNotificationScheduled(
    DateTime todayDateOnly,
  ) async {
    final streakCount = CacheHelper.getInt(_streakCountKey);

    if (streakCount <= 0) {
      debugPrint('⏰ No active Streak - notification NOT needed');
      return;
    }

    // Check if notification is already scheduled for tomorrow
    final isScheduled = await NotificationHelper.isNotificationScheduled(
      notificationId,
    );

    if (!isScheduled) {
      debugPrint('⚠️ Notification missing! Rescheduling...');
      await _scheduleStreakWarning(todayDateOnly);
    } else {
      debugPrint('✅ Notification already scheduled for tomorrow');
    }
  }

  // 🔴 CRITICAL FIX #4: Removed duplicate scheduling prevention logic
  // The old logic prevented notifications from being rescheduled properly
  static Future<void> _scheduleStreakWarning(DateTime todayDateOnly) async {
    final streakCount = CacheHelper.getInt(_streakCountKey);

    if (streakCount <= 0) {
      debugPrint('⏰ No active Streak - notification NOT scheduled');
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

    String title = "streak_reminder_title".tr();
    String body = "streak_reminder_body".tr();

    // Fallback for uninitialized translations
    if (title == "streak_reminder_title") {
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
        'type': 'Streak_warning',
        'streak_count': streakCount,
        'scheduled_date': tomorrow.toIso8601String(),
      },
    );

    // Save when we scheduled this notification
    CacheHelper.setString(
      _lastNotificationScheduledKey,
      tomorrow.toIso8601String(),
    );

    debugPrint(
      '⏰ Reminder scheduled for: ${DateFormat("yyyy-MM-dd hh:mm a").format(tomorrow)} | Streak: $streakCount',
    );

    _logEvent(
      'streak_notification_scheduled',
      parameters: {
        'streak_count': streakCount,
        'scheduled_time': tomorrow.toIso8601String(),
      },
    );
  }

  static int getStreakCount() {
    return CacheHelper.getInt(_streakCountKey);
  }

  /// Check if user's streak is in danger (didn't open today yet)
  static bool isStreakInDanger() {
    final lastOpenStr = CacheHelper.getString(_lastOpenKey);
    if (lastOpenStr.isEmpty) return false;

    final streakCount = CacheHelper.getInt(_streakCountKey);
    if (streakCount <= 0) return false;

    final lastOpen = DateTime.parse(lastOpenStr);
    final lastOpenDateOnly = _getDateOnly(lastOpen);
    final todayDateOnly = _getDateOnly(DateTime.now());

    final daysDifference = todayDateOnly.difference(lastOpenDateOnly).inDays;

    return daysDifference >= 1;
  }

  /// Reset streak manually
  static Future<void> resetStreak() async {
    final previousStreak = CacheHelper.getInt(_streakCountKey);

    debugPrint('🔄 Streak reset manually');

    CacheHelper.setInt(_streakCountKey, 0);
    streakNotifier.value = 0;
    CacheHelper.remove(_lastOpenKey);
    CacheHelper.remove(_lastNotificationScheduledKey);
    await NotificationHelper.cancel(notificationId);

    _logEvent(
      'streak_reset_manual',
      parameters: {'previous_count': previousStreak},
    );
  }

  /// Get Streak status information
  static Map<String, dynamic> getStreakStatus() {
    final lastOpenStr = CacheHelper.getString(_lastOpenKey);
    final streakCount = CacheHelper.getInt(_streakCountKey);

    if (lastOpenStr.isEmpty) {
      return {
        'streakCount': 0,
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
      'streakCount': streakCount,
      'isActive': streakCount > 0,
      'lastOpen': lastOpen,
      'daysSinceLastOpen': daysDifference,
      'isInDanger': daysDifference >= 1 && streakCount > 0,
      'openedToday': daysDifference == 0,
    };
  }

  // ==================== STATISTICS METHODS ====================

  /// Get the longest streak ever achieved
  static int getLongestStreak() {
    return CacheHelper.getInt(_longestStreakKey);
  }

  /// Get total number of active days (days app was opened)
  static int getTotalActiveDays() {
    return CacheHelper.getInt(_totalActiveDaysKey);
  }

  /// Get the date when current streak started
  static DateTime? getCurrentStreakStartDate() {
    final dateStr = CacheHelper.getString(_streakStartDateKey);
    if (dateStr.isEmpty) return null;
    return DateTime.parse(dateStr);
  }

  /// Get number of times streak was broken
  static int getStreakBreakCount() {
    return CacheHelper.getInt(_streakBreakCountKey);
  }

  /// Get average streak length from all past streaks
  static double getAverageStreakLength() {
    final allStreaksJson = CacheHelper.getString(_allStreaksKey);
    if (allStreaksJson.isEmpty) return 0.0;

    try {
      final List<dynamic> streaks = jsonDecode(allStreaksJson);
      if (streaks.isEmpty) return 0.0;

      final total = streaks.fold<int>(
        0,
        (sum, streak) => sum + (streak as int),
      );
      return total / streaks.length;
    } catch (e) {
      debugPrint('Error parsing streaks: $e');
      return 0.0;
    }
  }

  /// Get activity for last N days (returns list of dates)
  static List<DateTime> getLastNDaysActivity(int days) {
    final activeDaysJson = CacheHelper.getString(_activeDaysListKey);
    if (activeDaysJson.isEmpty) return [];

    try {
      final List<dynamic> dateStrings = jsonDecode(activeDaysJson);
      final List<DateTime> dates = dateStrings
          .map((str) => DateTime.parse(str as String))
          .toList();

      // Filter to last N days
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      return dates.where((date) => date.isAfter(cutoffDate)).toList();
    } catch (e) {
      debugPrint('Error parsing active days: $e');
      return [];
    }
  }

  /// Get achieved milestones
  static List<int> getAchievedMilestones() {
    final milestonesJson = CacheHelper.getString(_achievedMilestonesKey);
    if (milestonesJson.isEmpty) return [];

    try {
      final List<dynamic> achieved = jsonDecode(milestonesJson);
      return achieved.cast<int>();
    } catch (e) {
      debugPrint('Error parsing milestones: $e');
      return [];
    }
  }

  /// Get next milestone to achieve
  static int? getNextMilestone() {
    final currentStreak = getStreakCount();
    final achieved = getAchievedMilestones();

    for (final milestone in milestones) {
      if (!achieved.contains(milestone) && currentStreak < milestone) {
        return milestone;
      }
    }
    return null; // All milestones achieved
  }

  /// Check if a milestone was just achieved and return celebration data
  static Map<String, dynamic>? checkMilestoneAchievement(int newStreak) {
    if (!milestones.contains(newStreak)) return null;

    final lastCelebration = CacheHelper.getString(_lastCelebrationKey);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastCelebration == today) return null;

    final achieved = getAchievedMilestones();

    // Check if this milestone was already achieved
    if (achieved.contains(newStreak)) {
      debugPrint('⚠️ Milestone $newStreak already achieved, skipping');
      return null;
    }

    achieved.add(newStreak);
    CacheHelper.setString(_achievedMilestonesKey, jsonEncode(achieved));
    CacheHelper.setString(_lastCelebrationKey, today);

    // ✅ Enhanced Firebase Analytics logging for milestone achievement
    if (kReleaseMode) {
      final milestoneName = milestoneNames[newStreak] ?? 'unknown';

      _logEvent(
        'streak_milestone_achieved',
        parameters: {
          'milestone_days': newStreak,
          'milestone_name': milestoneName,
          'current_streak': newStreak,
          'total_active_days': getTotalActiveDays(),
          'longest_streak': getLongestStreak(),
          'date': today,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Also log individual milestone events for better tracking
      _logEvent(
        'milestone_${newStreak}_days',
        parameters: {
          'milestone_name': milestoneName,
          'achievement_date': today,
          'total_active_days': getTotalActiveDays(),
        },
      );

      debugPrint('📊 Firebase: Milestone $newStreak ($milestoneName) logged');
    }

    debugPrint('🎉 Milestone achieved: $newStreak days!');

    final celebrationData = {
      'milestone': newStreak,
      'name': milestoneNames[newStreak] ?? 'milestone',
      'shouldCelebrate': true,
    };

    CacheHelper.setString(_pendingCelebrationKey, jsonEncode(celebrationData));
    _milestoneController.add(celebrationData);

    return celebrationData;
  }

  /// Get and clear any pending celebration
  static Map<String, dynamic>? getPendingCelebration() {
    try {
      final celebrationJson = CacheHelper.getString(_pendingCelebrationKey);
      if (celebrationJson.isEmpty) return null;

      // Clear it immediately so it doesn't trigger again
      CacheHelper.remove(_pendingCelebrationKey);

      final data = jsonDecode(celebrationJson) as Map<String, dynamic>;
      debugPrint('🎊 Retrieved pending celebration: ${data['milestone']} days');
      return data;
    } catch (e) {
      debugPrint('❌ Error getting pending celebration: $e');
      CacheHelper.remove(_pendingCelebrationKey);
      return null;
    }
  }

  /// Update statistics when app is opened
  static void _updateStatistics(int newStreak, bool isNewDay) {
    if (!isNewDay) return; // Only update on new days

    // Update total active days
    final totalDays = getTotalActiveDays() + 1;
    CacheHelper.setInt(_totalActiveDaysKey, totalDays);

    // Update active days list
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final activeDaysJson = CacheHelper.getString(_activeDaysListKey);
    List<String> activeDays = [];

    if (activeDaysJson.isNotEmpty) {
      try {
        activeDays = (jsonDecode(activeDaysJson) as List<dynamic>)
            .cast<String>();
      } catch (e) {
        debugPrint('Error parsing active days: $e');
      }
    }

    if (!activeDays.contains(todayStr)) {
      activeDays.add(todayStr);
      CacheHelper.setString(_activeDaysListKey, jsonEncode(activeDays));
    }

    // Update longest streak
    final longestStreak = getLongestStreak();
    if (newStreak > longestStreak) {
      CacheHelper.setInt(_longestStreakKey, newStreak);
      debugPrint('🏆 New longest streak: $newStreak days!');
    }

    // Set streak start date if this is day 1
    if (newStreak == 1) {
      CacheHelper.setString(_streakStartDateKey, today.toIso8601String());
    }
  }

  /// Record a streak break
  static void _recordStreakBreak(int previousStreak) {
    if (previousStreak <= 0) return;

    // Increment break count
    final breakCount = getStreakBreakCount() + 1;
    CacheHelper.setInt(_streakBreakCountKey, breakCount);

    // Add previous streak to all streaks list
    final allStreaksJson = CacheHelper.getString(_allStreaksKey);
    List<int> allStreaks = [];

    if (allStreaksJson.isNotEmpty) {
      try {
        allStreaks = (jsonDecode(allStreaksJson) as List<dynamic>).cast<int>();
      } catch (e) {
        debugPrint('Error parsing all streaks: $e');
      }
    }

    allStreaks.add(previousStreak);
    CacheHelper.setString(_allStreaksKey, jsonEncode(allStreaks));

    debugPrint('💔 Streak break recorded. Previous streak: $previousStreak');
  }

  /// Get comprehensive statistics for display
  static Map<String, dynamic> getComprehensiveStats() {
    final currentStreak = getStreakCount();
    final longestStreak = getLongestStreak();
    final totalActiveDays = getTotalActiveDays();
    final streakBreaks = getStreakBreakCount();
    final averageStreak = getAverageStreakLength();
    final last7Days = getLastNDaysActivity(7);
    final last30Days = getLastNDaysActivity(30);
    final achievedMilestones = getAchievedMilestones();
    final nextMilestone = getNextMilestone();
    final streakStartDate = getCurrentStreakStartDate();

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalActiveDays': totalActiveDays,
      'streakBreaks': streakBreaks,
      'averageStreak': averageStreak,
      'last7DaysCount': last7Days.length,
      'last30DaysCount': last30Days.length,
      'last7Days': last7Days,
      'last30Days': last30Days,
      'achievedMilestones': achievedMilestones,
      'nextMilestone': nextMilestone,
      'streakStartDate': streakStartDate,
      'daysToNextMilestone': nextMilestone != null
          ? nextMilestone - currentStreak
          : 0,
    };
  }
}
