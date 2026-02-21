import 'package:hive/hive.dart';

class HistoryDBProvider {
  HistoryDBProvider._();

  static const String _boxName = 'zikrHistoryBox';
  static const String _counterBoxName = 'zikrCounterBox';
  static Box<List<String>>? _box;
  static Box<int>? _counterBox;

  /// Initialize Hive box
  static Future<void> init() async {
    _box = await Hive.openBox<List<String>>(_boxName);
    _counterBox = await Hive.openBox<int>(_counterBoxName);
  }

  static Box<List<String>> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw HiveError('HistoryDBProvider box is not open');
    }
    return _box!;
  }

  /// Add a check for a zikr (prevents duplicates for the same day)
  static Future<void> addCheck(String zikrId, DateTime date) async {
    final List<String> currentChecks = _safeBox.get(zikrId) ?? [];
    final today = DateTime(date.year, date.month, date.day);

    // ✅ Remove ANY existing entries for today first
    currentChecks.removeWhere((dateStr) {
      try {
        final d = DateTime.parse(dateStr);
        final dYMD = DateTime(d.year, d.month, d.day);
        return dYMD.isAtSameMomentAs(today);
      } catch (e) {
        return false; // Keep invalid entries for now
      }
    });

    // ✅ Now add the new entry
    final dateStr = date.toIso8601String();
    currentChecks.add(dateStr);

    await _safeBox.put(zikrId, currentChecks);
  }

  /// Remove today's check (removes ALL entries for the given date)
  static Future<void> removeCheck(String zikrId, DateTime date) async {
    final List<String> currentChecks = _safeBox.get(zikrId) ?? [];
    final today = DateTime(date.year, date.month, date.day);

    // ✅ Remove ALL entries for this date
    currentChecks.removeWhere((dateStr) {
      try {
        final d = DateTime.parse(dateStr);
        final dYMD = DateTime(d.year, d.month, d.day);
        return dYMD.isAtSameMomentAs(today);
      } catch (e) {
        return false; // Keep invalid entries
      }
    });

    await _safeBox.put(zikrId, currentChecks);
  }

  /// Get all checks as DateTime (removes duplicates)
  static List<DateTime> getChecks(String zikrId) {
    final List<String>? checkStrings = _box?.get(zikrId);
    if (checkStrings == null) return [];

    // ✅ Parse and deduplicate by date (not timestamp)
    final Map<String, DateTime> uniqueDates = {};

    for (final dateStr in checkStrings) {
      try {
        final date = DateTime.parse(dateStr);
        final dateKey = '${date.year}-${date.month}-${date.day}';

        // Keep only one entry per day (the first one encountered)
        if (!uniqueDates.containsKey(dateKey)) {
          uniqueDates[dateKey] = date;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    return uniqueDates.values.toList()..sort();
  }

  /// ✅ Synchronous check if zikr is checked today
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

  /// Optional: save check state explicitly (used in widget)
  static Future<void> saveCheckState(String zikrId, bool state) async {
    if (state) {
      await addCheck(zikrId, DateTime.now());
    } else {
      await removeCheck(zikrId, DateTime.now());
    }
  }

  /// ✅ Cleanup method to remove all duplicates from existing data
  static Future<void> cleanupDuplicates() async {
    final allKeys = _safeBox.keys;

    for (final key in allKeys) {
      if (key is! String) continue;

      final List<String>? checkStrings = _safeBox.get(key);
      if (checkStrings == null || checkStrings.isEmpty) continue;

      // Deduplicate
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

      // Save cleaned data
      await _safeBox.put(key, uniqueDates.values.toList());
    }
  }

  /// ✅ Counters logic

  static String _getCounterKey(String zikrId) {
    final today = DateTime.now();
    return '${zikrId}_${today.year}_${today.month}_${today.day}';
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
}
