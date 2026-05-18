import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ella_lyaabdoon/core/services/cache_helper.dart';
import 'package:ella_lyaabdoon/core/services/app_services_database_provider.dart';
import 'package:ella_lyaabdoon/features/history/data/history_db_provider.dart';
import 'package:ella_lyaabdoon/core/services/location_storage.dart';

/// Safely reads any value from Hive and converts it to a JSON-safe type.
/// Hive stores exactly what you put in — if someone did box.put(key, 123)
/// on a Box<String>, the runtime type is still int. We handle that here.
dynamic _toJsonSafe(dynamic value) {
  if (value == null) return null;
  if (value is String || value is int || value is double || value is bool) {
    return value;
  }
  if (value is List) return value.map(_toJsonSafe).toList();
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _toJsonSafe(v)));
  }
  // Fallback: toString() so we never crash
  return value.toString();
}

/// Result returned by [DataExportImportService.importAllData].
/// Carries everything the UI needs to react to the import without the
/// service needing a BuildContext.
class ImportResult {
  const ImportResult({required this.success, this.restoredLocale});

  /// Whether the import completed without fatal errors.
  final bool success;

  /// The locale code found in the backup (e.g. 'ar', 'en').
  /// Null if the backup had no locale or import failed.
  final String? restoredLocale;
}

class DataExportImportService {
  DataExportImportService._();

  static const String _appVersion = '1.0.0';
  static const String _dataType = 'ella_lyaabdoon_backup';

  // ─────────────────────────────────────────────────────────────────────────
  // EXPORT
  // ─────────────────────────────────────────────────────────────────────────

  static Future<String> exportAllData() async {
    final exportData = <String, dynamic>{
      'version': _appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'type': _dataType,
      'appServices': _exportBox<String>(AppDatabaseKeys.appServicesKey),
      'history': _exportHistoryData(),
      'cache': _exportCacheData(),
      'location': await _exportLocationData(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Generic box exporter — works for any Hive box that is already open.
  /// Uses [_toJsonSafe] so mismatched runtime types never throw.
  static Map<String, dynamic> _exportBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      debugPrint('⚠️ Export skipped — box not open: $boxName');
      return {};
    }

    final box = Hive.box<T>(boxName);
    final result = <String, dynamic>{};

    for (final key in box.keys) {
      final raw = box.get(key);
      result[key.toString()] = _toJsonSafe(raw);
    }

    return result;
  }

  static Map<String, dynamic> _exportHistoryData() {
    final result = <String, dynamic>{};

    // zikrHistoryBox — Box<List<String>>
    result['zikrHistoryBox'] = _exportTypedListBox('zikrHistoryBox');

    // zikrCounterBox — Box<int>
    result['zikrCounterBox'] = _exportIntBox('zikrCounterBox');

    // appOpensBox — Box<List<String>>
    result['appOpensBox'] = _exportTypedListBox('appOpensBox');

    return result;
  }

  static Map<String, dynamic> _exportTypedListBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      debugPrint('⚠️ Export skipped — box not open: $boxName');
      return {};
    }

    final box = Hive.box<List<String>>(boxName);
    final result = <String, dynamic>{};

    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        // Store as List<String> — safe for JSON
        result[key.toString()] = List<String>.from(value);
      }
    }

    return result;
  }

  static Map<String, dynamic> _exportIntBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      debugPrint('⚠️ Export skipped — box not open: $boxName');
      return {};
    }

    final box = Hive.box<int>(boxName);
    final result = <String, dynamic>{};

    for (final key in box.keys) {
      final value = box.get(key);
      if (value != null) {
        result[key.toString()] = value;
      }
    }

    return result;
  }

  /// Exports SharedPreferences cache.
  /// Each key is read with the correct typed getter to avoid type confusion.
  static Map<String, dynamic> _exportCacheData() {
    // Keys that are stored as bool
    const boolKeys = {
      'showCaseKey',
      'isTermsAcceptedKey5',
      'statisticsMigrated_v1',
      'settings_showcase_shown2',
    };

    // Keys that are stored as int
    const intKeys = {
      'strikeCount',
      'longestStreak',
      'totalActiveDays',
      'streakBreakCount',
      'usedStreakSavesCount',
    };

    // All remaining string keys
    const stringKeys = {
      'lastOpenDate',
      'streakStartDate',
      'allStreaks',
      'activeDaysList',
      'achievedMilestones',
      'lastCelebration',
      'pendingCelebration',
      'usedStreakSavesMonth',
      'startTimeKey',
      'counterTapHintKey3',
    };

    final result = <String, dynamic>{};
    // SharedPreferences throws a hard type-cast error if you call getString()
    // on a key that was saved with setBool() or setInt() — and vice-versa.
    // The only safe pattern without exposing the raw SharedPreferences instance
    // is to call the correct typed getter and catch any stray type errors.

    for (final key in boolKeys) {
      try {
        result[key] = CacheHelper.getBool(key);
      } catch (e) {
        debugPrint('⚠️ Skipping bool key "$key": $e');
      }
    }

    for (final key in intKeys) {
      try {
        result[key] = CacheHelper.getInt(key);
      } catch (e) {
        debugPrint('⚠️ Skipping int key "$key": $e');
      }
    }

    for (final key in stringKeys) {
      try {
        final value = CacheHelper.getString(key);
        if (value.isNotEmpty) result[key] = value;
      } catch (e) {
        debugPrint('⚠️ Skipping string key "$key": $e');
      }
    }

    return result;
  }

  static Future<Map<String, dynamic>> _exportLocationData() async {
    return {
      'latitude': await LocationStorage.getLat(),
      'longitude': await LocationStorage.getLng(),
      'city': await LocationStorage.getCity(),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FILE I/O — EXPORT
  // ─────────────────────────────────────────────────────────────────────────

  static Future<File?> saveExportToFile() async {
    try {
      final jsonData = await exportAllData();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File(
        '${directory.path}/ella_lyaabdoon_backup_$timestamp.json',
      );
      await file.writeAsString(jsonData, flush: true);
      return file;
    } catch (e, st) {
      debugPrint('❌ Error saving export file: $e\n$st');
      return null;
    }
  }

  static Future<bool> shareExport() async {
    final file = await saveExportToFile();
    if (file == null) return false;
    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Ella Lyaabdoon Backup Data');
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FILE I/O — IMPORT
  // ─────────────────────────────────────────────────────────────────────────

  static Future<String?> pickImportFile() async {
    try {
      // FileType.custom with 'json' is unsupported on Android — the system
      // picker doesn't whitelist it as a MIME type. Use FileType.any and
      // validate the extension ourselves after the user picks.
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null) return null;

      final filePath = result.files.single.path;
      if (filePath == null) return null;

      if (!filePath.toLowerCase().endsWith('.json')) {
        debugPrint('❌ Selected file is not a .json file: $filePath');
        return null; // caller should surface an "invalid file type" message
      }

      return await File(filePath).readAsString();
    } catch (e) {
      debugPrint('❌ Error picking import file: $e');
      return null;
    }
  }

  /// Parses and validates the backup JSON.
  /// Returns null if the file is invalid or the wrong type.
  static Future<Map<String, dynamic>?> parseImportData(
    String jsonString,
  ) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data['type'] != _dataType) {
        debugPrint('❌ Invalid backup type: ${data['type']}');
        return null;
      }

      return data;
    } catch (e) {
      debugPrint('❌ Error parsing import data: $e');
      return null;
    }
  }

  /// Full import — restores all data from a backup JSON string.
  /// Returns an [ImportResult] so the caller can react to locale changes
  /// and other side-effects without needing a BuildContext here.
  static Future<ImportResult> importAllData(String jsonString) async {
    try {
      final data = await parseImportData(jsonString);
      if (data == null) return const ImportResult(success: false);

      await _importAppServices(data['appServices'] as Map<String, dynamic>?);
      await _importHistoryData(data['history'] as Map<String, dynamic>?);
      await _importCacheData(data['cache'] as Map<String, dynamic>?);
      await _importLocationData(data['location'] as Map<String, dynamic>?);

      // Extract the restored locale so the UI can apply it via EasyLocalization
      // without this service needing a BuildContext.
      final appServices = data['appServices'] as Map<String, dynamic>?;
      final restoredLocale = appServices?[AppDatabaseKeys.localeKey] as String?;

      return ImportResult(success: true, restoredLocale: restoredLocale);
    } catch (e, st) {
      debugPrint('❌ Error importing data: $e\n$st');
      return const ImportResult(success: false);
    }
  }

  static Future<ImportResult> importFromFile() async {
    final jsonString = await pickImportFile();
    if (jsonString == null) return const ImportResult(success: false);
    return importAllData(jsonString);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IMPORT — individual sections
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _importAppServices(Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;

    final box = Hive.box<String>(AppDatabaseKeys.appServicesKey);

    for (final entry in data.entries) {
      if (entry.value == null) continue;
      // Always store as String — this is a Box<String>
      await box.put(entry.key, entry.value.toString());
    }
  }

  static Future<void> _importHistoryData(Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;

    await _importTypedListBox(
      'zikrHistoryBox',
      data['zikrHistoryBox'] as Map<String, dynamic>?,
    );

    await _importIntBox(
      'zikrCounterBox',
      data['zikrCounterBox'] as Map<String, dynamic>?,
    );

    await _importTypedListBox(
      'appOpensBox',
      data['appOpensBox'] as Map<String, dynamic>?,
    );
  }

  static Future<void> _importTypedListBox(
    String boxName,
    Map<String, dynamic>? data,
  ) async {
    if (data == null || data.isEmpty) return;

    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<List<String>>(boxName)
          : await Hive.openBox<List<String>>(boxName);

      for (final entry in data.entries) {
        if (entry.value is! List) continue;
        final list = (entry.value as List).map((e) => e.toString()).toList();
        await box.put(entry.key, list);
      }
    } catch (e) {
      debugPrint('❌ Error importing $boxName: $e');
    }
  }

  static Future<void> _importIntBox(
    String boxName,
    Map<String, dynamic>? data,
  ) async {
    if (data == null || data.isEmpty) return;

    try {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<int>(boxName)
          : await Hive.openBox<int>(boxName);

      for (final entry in data.entries) {
        final value = entry.value;
        if (value is int) {
          await box.put(entry.key, value);
        } else if (value is num) {
          await box.put(entry.key, value.toInt());
        }
        // Skip if not numeric — don't crash
      }
    } catch (e) {
      debugPrint('❌ Error importing $boxName: $e');
    }
  }

  /// Restores SharedPreferences cache.
  /// Uses the correct typed setter for each key to avoid SharedPreferences
  /// type mismatch errors on the next read.
  static Future<void> _importCacheData(Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;

    const boolKeys = {
      'showCaseKey',
      'isTermsAcceptedKey5',
      'statisticsMigrated_v1',
      'settings_showcase_shown2',
    };

    const intKeys = {
      'strikeCount',
      'longestStreak',
      'totalActiveDays',
      'streakBreakCount',
      'usedStreakSavesCount',
    };

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value == null) continue;

      try {
        if (boolKeys.contains(key)) {
          // Stored value might come back as bool or string '1'/'true'
          final asBool = value is bool
              ? value
              : value.toString() == 'true' || value.toString() == '1';
          await CacheHelper.setBool(key, asBool);
        } else if (intKeys.contains(key)) {
          final asInt = value is int
              ? value
              : int.tryParse(value.toString()) ?? 0;
          await CacheHelper.setInt(key, asInt);
        } else {
          // Everything else is a string
          await CacheHelper.setString(key, value.toString());
        }
      } catch (e) {
        debugPrint('⚠️ Skipping cache key "$key": $e');
      }
    }
  }

  static Future<void> _importLocationData(Map<String, dynamic>? data) async {
    if (data == null) return;

    final lat = data['latitude'];
    final lng = data['longitude'];
    final city = data['city'];

    if (lat != null && lng != null) {
      await LocationStorage.saveLocation(
        (lat as num).toDouble(),
        (lng as num).toDouble(),
      );
    }

    if (city is String && city.isNotEmpty) {
      await LocationStorage.saveCity(city);
    }
  }
}
