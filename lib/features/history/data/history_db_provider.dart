import 'package:ella_lyaabdoon/core/constants/app_lists.dart';
import 'package:ella_lyaabdoon/core/models/azan_day_period.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HistoryDBProvider {
  HistoryDBProvider._();

  static const String _boxName = 'zikrHistoryBox';
  static const String _counterBoxName = 'zikrCounterBox';
  static const String _appOpensBoxName = 'appOpensBox';
  static Box<List<String>>? _box;
  static Box<int>? _counterBox;
  static Box<List<String>>? _appOpensBox;

  /// Initialize Hive box
  static Future<void> init() async {
    _box = await Hive.openBox<List<String>>(_boxName);
    _counterBox = await Hive.openBox<int>(_counterBoxName);
    _appOpensBox = await Hive.openBox<List<String>>(_appOpensBoxName);
  }

  /// Reload the boxes from disk to sync changes made by background isolates
  static Future<void> reload() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
      }
      _box = await Hive.openBox<List<String>>(_boxName);
    } catch (e) {
      debugPrint('⚠️ Error reloading HistoryDBProvider: $e');
    }
  }

  static Box<List<String>> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw HiveError('HistoryDBProvider box is not open');
    }
    return _box!;
  }

  /// Saturday = start of week (weekday=6)
  /// Returns how many days back from today to reach the last Saturday
  static DateTime _getWeekStart(DateTime today) {
    // Dart: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
    // Days since last Saturday:
    // Sat=0, Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6
    final daysSinceSaturday = (today.weekday + 1) % 7;
    return today.subtract(Duration(days: daysSinceSaturday));
  }

  static int getZikrsThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _getWeekStart(today);
    final daysElapsed = today.difference(weekStart).inDays; // 0..6

    int total = 0;
    for (int i = 0; i <= daysElapsed; i++) {
      total += getTotalZikrsCompletedForDate(weekStart.add(Duration(days: i)));
    }
    return total;
  }

  static int getZikrsLastWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = _getWeekStart(today);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

    int total = 0;
    for (int i = 0; i < 7; i++) {
      total += getTotalZikrsCompletedForDate(
        lastWeekStart.add(Duration(days: i)),
      );
    }
    return total;
  }

  static Map<int, int> getWeekZikrCountsFromSaturday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _getWeekStart(
      today,
    ); // already defined — returns last Saturday
    final daysElapsed = today.difference(weekStart).inDays; // 0..6

    final result = <int, int>{};
    for (int i = 0; i <= 6; i++) {
      final date = weekStart.add(Duration(days: i));
      result[i] = i <= daysElapsed
          ? getTotalZikrsCompletedForDate(date)
          : 0; // future days = 0
    }
    return result;
  }

  static int getAppOpensThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _getWeekStart(today);
    return getAppOpensForDateRange(weekStart, today);
  }

  static DateTime getWeekStart(DateTime today) {
    final daysSinceSaturday = (today.weekday + 1) % 7;
    return today.subtract(Duration(days: daysSinceSaturday));
  }

  static int getAppOpensLastWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = _getWeekStart(today);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    return getAppOpensForDateRange(lastWeekStart, lastWeekEnd);
  }

  /// Add a check for a zikr (prevents duplicates for the same day)
  static Future<void> addCheck(String zikrId, DateTime date) async {
    // ✅ Copy to avoid mutating Hive's in-memory reference directly
    final List<String> currentChecks = List<String>.from(
      _safeBox.get(zikrId) ?? [],
    );
    final today = DateTime(date.year, date.month, date.day);

    // Remove ANY existing entries for today first
    currentChecks.removeWhere((dateStr) {
      try {
        final d = DateTime.parse(dateStr);
        final dYMD = DateTime(d.year, d.month, d.day);
        return dYMD.isAtSameMomentAs(today);
      } catch (e) {
        return false;
      }
    });

    // Add the new entry
    final dateStr = date.toIso8601String();
    currentChecks.add(dateStr);

    await _safeBox.put(zikrId, currentChecks);
  }

  /// Remove today's check (removes ALL entries for the given date)
  static Future<void> removeCheck(String zikrId, DateTime date) async {
    // ✅ Copy to avoid mutating Hive's in-memory reference directly
    final List<String> currentChecks = List<String>.from(
      _safeBox.get(zikrId) ?? [],
    );
    final today = DateTime(date.year, date.month, date.day);

    currentChecks.removeWhere((dateStr) {
      try {
        final d = DateTime.parse(dateStr);
        final dYMD = DateTime(d.year, d.month, d.day);
        return dYMD.isAtSameMomentAs(today);
      } catch (e) {
        return false;
      }
    });

    await _safeBox.put(zikrId, currentChecks);
  }

  /// Get all checks as DateTime (removes duplicates)
  static List<DateTime> getChecks(String zikrId) {
    final List<String>? checkStrings = _box?.get(zikrId);
    if (checkStrings == null) return [];

    // Parse and deduplicate by date (not timestamp)
    final Map<String, DateTime> uniqueDates = {};

    for (final dateStr in checkStrings) {
      try {
        final date = DateTime.parse(dateStr);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        // Keep only the first entry encountered per day
        if (!uniqueDates.containsKey(dateKey)) {
          uniqueDates[dateKey] = date;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    return uniqueDates.values.toList()..sort();
  }

  /// Synchronous check if zikr is checked today
  static bool isCheckedToday(String zikrId) {
    if (_box == null || !_box!.isOpen) return false;

    final today = DateTime.now();
    final todayYMD = DateTime(today.year, today.month, today.day);

    final checks = getChecks(zikrId);
    for (final check in checks) {
      final checkYMD = DateTime(check.year, check.month, check.day);
      if (checkYMD.isAtSameMomentAs(todayYMD)) return true;
    }
    return false;
  }

  /// Async version for widget background
  static Future<bool> isCheckedTodayAsync(String zikrId) async {
    return isCheckedToday(zikrId);
  }

  /// Save check state explicitly (used in widget)
  static Future<void> saveCheckState(String zikrId, bool state) async {
    if (state) {
      await addCheck(zikrId, DateTime.now());
    } else {
      await removeCheck(zikrId, DateTime.now());
    }
  }

  /// Cleanup method to remove all duplicates from existing data
  static Future<void> cleanupDuplicates() async {
    final allKeys = _safeBox.keys;

    for (final key in allKeys) {
      if (key is! String) continue;

      final List<String>? checkStrings = _safeBox.get(key);
      if (checkStrings == null || checkStrings.isEmpty) continue;

      final Map<String, String> uniqueDates = {};
      for (final dateStr in checkStrings) {
        try {
          final date = DateTime.parse(dateStr);
          final dateKey = '${date.year}-${date.month}-${date.day}';

          if (!uniqueDates.containsKey(dateKey)) {
            uniqueDates[dateKey] = dateStr;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }

      await _safeBox.put(key, uniqueDates.values.toList());
    }
  }

  // ──────────────────────────────────────────────────────────
  // Counters logic
  // ──────────────────────────────────────────────────────────

  /// Returns a key scoped to today's date for a given zikrId
  static String _getCounterKey(String zikrId) {
    final today = DateTime.now();
    return '${zikrId}_${today.year}_${today.month}_${today.day}';
  }
  // ──────────────────────────────────────────────────────────
  // Monthly Aggregations
  // ──────────────────────────────────────────────────────────

  static int getZikrsThisMonth() {
    final now = DateTime.now();
    return getZikrsForMonth(now.year, now.month);
  }

  static int getZikrsLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return getZikrsForMonth(lastMonth.year, lastMonth.month);
  }

  static int getZikrsLast3Months() {
    final now = DateTime.now();
    int total = 0;

    for (int i = 0; i < 3; i++) {
      final date = DateTime(now.year, now.month - i);
      total += getZikrsForMonth(date.year, date.month);
    }

    return total;
  }

  static int getZikrsLast6Months() {
    final now = DateTime.now();
    int total = 0;

    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i);
      total += getZikrsForMonth(date.year, date.month);
    }

    return total;
  }

  static int getZikrsAllTime() {
    if (_box == null || !_box!.isOpen) return 0;

    int total = 0;

    final allRewards = AppLists.timelineItems
        .expand((item) => item.rewards)
        .toList();

    for (final reward in allRewards) {
      final checks = getChecks(reward.id);
      total += checks.length; // already deduplicated per day
    }

    return total;
  }
  // ──────────────────────────────────────────────────────────
  // Insights / Analytics
  // ──────────────────────────────────────────────────────────

  /// Average zikrs per day for current week (Mon → today)
  static double getWeeklyAverageZikrs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _getWeekStart(today);
    final daysCount = today.difference(weekStart).inDays + 1; // 1..7

    int total = 0;
    for (int i = 0; i < daysCount; i++) {
      total += getTotalZikrsCompletedForDate(weekStart.add(Duration(days: i)));
    }
    return total / daysCount;
  }

  /// Completion rate (%) over last N days
  /// = days with at least 1 zikr / total days * 100
  static int getCompletionRate(int days) {
    if (days <= 0) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int completedDays = 0;

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final count = getTotalZikrsCompletedForDate(date);
      if (count > 0) completedDays++;
    }

    return ((completedDays / days) * 100).round();
  }

  /// Best day of week based on total zikr count
  /// Returns: 0=Mon ... 6=Sun, or -1 if no data
  static int getBestDayOfWeek() {
    if (_box == null || !_box!.isOpen) return -1;

    final totals = List<int>.filled(7, 0); // Mon=0 ... Sun=6

    final allRewards = AppLists.timelineItems
        .expand((item) => item.rewards)
        .toList();

    for (final reward in allRewards) {
      final checks = getChecks(reward.id);

      for (final check in checks) {
        final weekdayIndex = check.weekday - 1; // Mon=0
        if (weekdayIndex >= 0 && weekdayIndex < 7) {
          totals[weekdayIndex]++;
        }
      }
    }

    int max = 0;
    int bestIndex = -1;

    for (int i = 0; i < 7; i++) {
      if (totals[i] > max) {
        max = totals[i];
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  /// Get current count for a zikr today
  static int getCounter(String zikrId) {
    if (_counterBox == null || !_counterBox!.isOpen) return 0;
    return _counterBox!.get(_getCounterKey(zikrId)) ?? 0;
  }

  /// Increment counter for a zikr today
  static Future<void> incrementCounter(String zikrId) async {
    if (_counterBox == null || !_counterBox!.isOpen) return;
    final key = _getCounterKey(zikrId);
    final current = _counterBox!.get(key) ?? 0;
    await _counterBox!.put(key, current + 1);
  }

  /// Reset counter for a zikr today
  static Future<void> resetCounter(String zikrId) async {
    if (_counterBox == null || !_counterBox!.isOpen) return;
    await _counterBox!.delete(_getCounterKey(zikrId));
  }

  // ──────────────────────────────────────────────────────────
  // App Opens Tracking
  // ──────────────────────────────────────────────────────────

  static const String _appOpensKey = 'app_opens_dates';

  /// Record that the app was opened today (prevents duplicate for the same day)
  static Future<void> recordAppOpen() async {
    if (_appOpensBox == null || !_appOpensBox!.isOpen) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // ✅ Always copy the list — never mutate the object Hive holds in memory.
    // Hive tracks changes by reference: if you mutate the same list instance
    // it returned, it may skip the disk write → data lost on hot restart / kill.
    final List<String> opens = List<String>.from(
      _appOpensBox!.get(_appOpensKey) ?? [],
    );

    if (!opens.contains(todayStr)) {
      opens.add(todayStr);
      await _appOpensBox!.put(_appOpensKey, opens);
    }
  }

  /// Get app opens count for a date range (inclusive)
  static int getAppOpensForDateRange(DateTime start, DateTime end) {
    if (_appOpensBox == null || !_appOpensBox!.isOpen) return 0;

    final opens = _appOpensBox!.get(_appOpensKey) ?? [];
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    int count = 0;
    for (final dateStr in opens) {
      try {
        final parts = dateStr.split('-');
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        if (!date.isBefore(startDate) && !date.isAfter(endDate)) {
          count++;
        }
      } catch (_) {}
    }
    return count;
  }

  /// ✅ Get daily app opens for the last N days as a map of dayIndex → 1/0
  /// Index 0 = oldest day, index N-1 = today
  static Map<int, int> getDailyAppOpens(int days) =>
      getDailyAppOpensRange(days);

  /// ✅ [New] Get daily app opens for an arbitrary range (N days back from today)
  /// Returns map of dayIndex → 1 (opened) or 0 (not opened)
  /// Index 0 = N-1 days ago, index N-1 = today
  static Map<int, int> getDailyAppOpensRange(int days) {
    final result = <int, int>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final opens = _appOpensBox?.get(_appOpensKey) ?? [];

    for (int i = 0; i < days; i++) {
      // i=0 is the oldest day (days-1 days ago), i=days-1 is today
      final date = today.subtract(Duration(days: days - 1 - i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[i] = opens.contains(dateStr) ? 1 : 0;
    }
    return result;
  }

  // ──────────────────────────────────────────────────────────
  // Daily Zikr Completion Aggregation
  // ──────────────────────────────────────────────────────────

  /// Get total zikrs completed for a specific date across all rewards
  static int getTotalZikrsCompletedForDate(DateTime date) {
    if (_box == null || !_box!.isOpen) return 0;

    final targetDate = DateTime(date.year, date.month, date.day);
    int total = 0;

    // ✅ Correct: collect all reward IDs from timeline
    final allRewards = AppLists.timelineItems
        .expand((item) => item.rewards)
        .toList();

    for (final reward in allRewards) {
      final checks = getChecks(reward.id);
      for (final check in checks) {
        final checkDate = DateTime(check.year, check.month, check.day);
        if (checkDate.isAtSameMomentAs(targetDate)) {
          total++; // Count one per reward per day (duplicates already removed in getChecks)
          break;
        }
      }
    }
    return total;
  }

  /// ✅ Get daily zikr counts for the last N days
  /// Index 0 = oldest day (N-1 days ago), index N-1 = today
  static Map<int, int> getDailyZikrCounts(int days) =>
      getDailyZikrCountsRange(days);

  /// ✅ [New] Get daily zikr counts for an arbitrary range (N days back from today)
  /// Returns map of dayIndex → zikr count
  /// Index 0 = N-1 days ago, index N-1 = today
  static Map<int, int> getDailyZikrCountsRange(int days) {
    final result = <int, int>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < days; i++) {
      // i=0 → oldest (days-1 days ago), i=days-1 → today
      final date = today.subtract(Duration(days: days - 1 - i));
      result[i] = getTotalZikrsCompletedForDate(date);
    }
    return result;
  }

  static int getZikrsForMonth(int year, int month) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0);

    int total = 0;
    for (int i = 0; ; i++) {
      final date = startOfMonth.add(Duration(days: i));
      if (date.isAfter(endOfMonth)) break;
      total += getTotalZikrsCompletedForDate(date);
    }
    return total;
  }

  // ──────────────────────────────────────────────────────────
  // Period Statistics
  // ──────────────────────────────────────────────────────────

  static int getZikrsPerPeriodToday(AzanDayPeriod period) {
    if (_box == null || !_box!.isOpen) return 0;

    int total = 0;
    try {
      final periodItem = AppLists.timelineItems.firstWhere(
        (item) => item.period == period,
      );
      for (final reward in periodItem.rewards) {
        if (isCheckedToday(reward.id)) {
          total++;
        }
      }
    } catch (e) {
      // Ignore
    }
    return total;
  }

  static int getZikrsPerPeriodAllTime(AzanDayPeriod period) {
    if (_box == null || !_box!.isOpen) return 0;

    int total = 0;
    try {
      final periodItem = AppLists.timelineItems.firstWhere(
        (item) => item.period == period,
      );
      for (final reward in periodItem.rewards) {
        final checks = getChecks(reward.id);
        total += checks.length;
      }
    } catch (e) {
      // Ignore
    }
    return total;
  }

  static Map<AzanDayPeriod, double> getPeriodCompletionRates() {
    final Map<AzanDayPeriod, double> rates = {};
    if (_box == null || !_box!.isOpen) return rates;

    for (final item in AppLists.timelineItems) {
      final totalToday = getZikrsPerPeriodToday(item.period);
      final count = item.rewards.length;
      if (count == 0) {
        rates[item.period] = 0.0;
      } else {
        rates[item.period] = totalToday / count;
      }
    }
    return rates;
  }

  // ──────────────────────────────────────────────────────────
  // ✅ [New] Today's Statistics convenience method
  // ──────────────────────────────────────────────────────────

  /// Returns a map with:
  ///   'zikrsToday'  → int: number of zikrs completed today
  ///   'openedToday' → bool: whether the app was opened today
  ///
  /// NOTE: openedToday is always true here — if this method is being
  /// called, the app is open right now. We do NOT read from the box
  /// because recordAppOpen() is async and may not have flushed yet,
  /// which would cause a false-negative on the very first build.
  static Map<String, dynamic> getTodayStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final zikrsToday = getTotalZikrsCompletedForDate(today);

    return {
      'zikrsToday': zikrsToday,
      'openedToday': true, // app is running → it was opened today by definition
    };
  }

  static void debugPrintAppOpens() {
    final opens = _appOpensBox?.get(_appOpensKey) ?? [];
    debugPrint('=== APP OPENS BOX ===');
    debugPrint('Total entries: ${opens.length}');
    for (final s in opens) {
      debugPrint('  → "$s"');
    }
    debugPrint('This week: ${getAppOpensThisWeek()}');
    debugPrint('=====================');
  }
}
