import 'package:shared_preferences/shared_preferences.dart';

class LocationStorage {
  static const _latKey = 'latitude12';
  static const _lngKey = 'longitude12';

  // Check if location is saved
  static Future<bool> hasLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_latKey) && prefs.containsKey(_lngKey);
  }

  // Get saved latitude
  static Future<double?> getLat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_latKey);
  }

  // Get saved longitude
  static Future<double?> getLng() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lngKey);
  }

  // Save latitude and longitude
  static Future<void> saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
  }

  // Clear saved location
  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latKey);
    await prefs.remove(_lngKey);
  }
}
