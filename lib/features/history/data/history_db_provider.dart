import 'package:hive/hive.dart';

class HistoryDBProvider {
  HistoryDBProvider._();

  static const String _boxName = 'zikrHistoryBox';
  static Box<List<String>>? _box;

  /// Initialize Hive box
  static Future<void> init() async {
    _box = await Hive.openBox<List<String>>(_boxName);
  }

  static Box<List<String>> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw HiveError('HistoryDBProvider box is not open');
    }
    return _box!;
  }

  /// Add a check for a zikr
  static Future<void> addCheck(String zikrId, DateTime date) async {
    final List<String> currentChecks = _safeBox.get(zikrId) ?? [];
    final dateStr = date.toIso8601String();

    currentChecks.add(dateStr);
    await _safeBox.put(zikrId, currentChecks);
  }

  /// Remove today's check
  static Future<void> removeCheck(String zikrId, DateTime date) async {
    final List<String> currentChecks = _safeBox.get(zikrId) ?? [];
    final today = DateTime(date.year, date.month, date.day);

    currentChecks.removeWhere((dateStr) {
      final d = DateTime.parse(dateStr);
      final dYMD = DateTime(d.year, d.month, d.day);
      return dYMD.isAtSameMomentAs(today);
    });

    await _safeBox.put(zikrId, currentChecks);
  }

  /// Get all checks as DateTime
  static List<DateTime> getChecks(String zikrId) {
    final List<String>? checkStrings = _box?.get(zikrId);
    if (checkStrings == null) return [];
    return checkStrings.map((s) => DateTime.parse(s)).toList();
  }

  /// ✅ Synchronous check if zikr is checked today (for in-app UI)
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
}
