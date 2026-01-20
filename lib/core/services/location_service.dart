import 'package:ella_lyaabdoon/core/services/location_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/dio_factory.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationService {
  // Dynamically get API key from env
  static String get _apiKey => dotenv.env['API_KEY_FOR_MAPS'] ?? '';

  static Future<String?> _getCityFromMapsCo(double lat, double lng) async {
    try {
      debugPrint('Getting city from maps.co...');
      final dio = DioFactory.getDio();

      final response = await dio.get(
        'https://geocode.maps.co/reverse',
        queryParameters: {'lat': lat, 'lon': lng, 'api_key': _apiKey},
      );

      final data = response.data as Map<String, dynamic>?;
      final address = data?['address'] as Map<String, dynamic>?;

      if (address == null) return null;

      return address['state'] ??
          address['city'] ??
          address['town'] ??
          address['suburb'];
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getCityFromMapsCo(double lat, double lng) async {
    try {
      final dio = DioFactory.getDio();

      final response = await dio.get(
        'https://geocode.maps.co/reverse',
        queryParameters: {'lat': lat, 'lon': lng, 'api_key': _apiKey},
      );

      final data = response.data as Map<String, dynamic>?;
      final address = data?['address'] as Map<String, dynamic>?;

      if (address == null) return null;

      // priority: state -> suburb
      return address['state'] ?? address['suburb'];
    } catch (_) {
      return null;
    }
  }

  // Get city name and print all placemark info from latitude and longitude
  /// Single entry point
  /// 1. Try native geocoding
  /// 2. On failure -> fallback to maps.co
  /// Main entry point
  static Future<String?> getCity(
    double lat,
    double lng, {
    bool forceRefresh = false,
  }) async {
    final cachedLat = await LocationStorage.getLat();
    final cachedLng = await LocationStorage.getLng();
    final cachedCity = await LocationStorage.getCity();

    // Use cached city only if lat/lng didn't change and not forced
    if (!forceRefresh &&
        cachedCity != null &&
        cachedCity.isNotEmpty &&
        cachedCity != 'Unknown' && // <-- add this check
        cachedLat == lat &&
        cachedLng == lng) {
      return cachedCity;
    }

    String? city;

    try {
      debugPrint('Getting city from coordinates...');
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.administrativeArea ?? p.subAdministrativeArea ?? p.locality;

        // Ignore empty or "Unknown" results
        if (city == null || city.isEmpty || city == 'Unknown') {
          city = null;
        }
      }
    } catch (_) {
      debugPrint('Error getting city from coordinates');
      city = null;
    }
    debugPrint('City from coordinates: $city');
    // 2️⃣ Fallback API
    city ??= await _getCityFromMapsCo(lat, lng);
    debugPrint('City from Maps.co: $city');
    // 3️⃣ Cache the new city and lat/lng
    if (city != null && city.isNotEmpty) {
      await LocationStorage.saveCity(city);
      await LocationStorage.saveLocation(lat, lng);
    }

    return city;
  }

  /// HTTP fallback only

  static Future<Position> determinePosition() async {
    print('Checking if location services are enabled...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled. Opening settings...');
      await Geolocator.openLocationSettings();
      throw 'Location services are disabled.';
    }

    print('Checking location permissions...');
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      print('Location permission denied, requesting permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission still denied.');
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied. Opening app settings...');
      await Geolocator.openAppSettings();
      throw 'Location permissions are permanently denied.';
    }

    print('Getting current position...');

    Position? position;
    position = await Geolocator.getLastKnownPosition();
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    print('Position retrieved:');
    print('  Latitude: ${position.latitude}');
    print('  Longitude: ${position.longitude}');
    print('  Accuracy: ${position.accuracy}');
    print('  Altitude: ${position.altitude}');
    print('  Speed: ${position.speed}');
    print('  Heading: ${position.heading}');
    // print('  Timestamp: ${position.timestamp}');

    return position;
  }
}
