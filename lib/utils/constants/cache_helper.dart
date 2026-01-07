import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static void setString(String key, String value) {
    _prefs?.setString(key, value);
  }

  static String getString(String key) {
    return _prefs?.getString(key) ?? ''; // Default to an empty string if null
  }

  static void setInt(String key, int value) {
    _prefs?.setInt(key, value);
  }

  static int getInt(String key) {
    return _prefs?.getInt(key) ?? 0; // Default to 0 if null
  }

  static void setDouble(String key, double value) {
    _prefs?.setDouble(key, value);
  }

  static double getDouble(String key) {
    return _prefs?.getDouble(key) ?? 0.0; // Default to 0.0 if null
  }

  static void setBool(String key, bool value) {
    _prefs?.setBool(key, value);
  }

  static bool getBool(String key) {
    return _prefs?.getBool(key) ?? false; // Default to false if null
  }

  static Future setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  static List<String> getStringList(String key) {
    return _prefs?.getStringList(
          key,
        ) ??
        [];
  }

  static void remove(String key) {
    _prefs?.remove(key);
  }

  static void clear() {
    _prefs?.clear();
  }
}

class CacheKeys {
  CacheKeys._();
  static const showCaseKey = "showCaseKey";
  static const isTermsAcceptedKey = "isTermsAcceptedKey5";
  static const dahabMasrFavListIdKey = "sand5asd4478";
  static const startTimeKey = "startTimeKey";
}
