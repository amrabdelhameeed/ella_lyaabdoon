import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Get city name and print all placemark info from latitude and longitude
  static Future<String?> getCity(double lat, double lng) async {
    print('Getting placemarks for latitude: $lat, longitude: $lng');

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      print('Placemark count: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        for (var i = 0; i < placemarks.length; i++) {
          final p = placemarks[i];
          print('Placemark #$i:');
          print('  Name: ${p.name}');
          print('  Street: ${p.street}');
          print('  SubLocality: ${p.subLocality}');
          print('  Locality (City): ${p.locality}');
          print('  Administrative Area: ${p.administrativeArea}');
          print('  SubAdministrative Area: ${p.subAdministrativeArea}');
          print('  Postal Code: ${p.postalCode}');
          print('  Country: ${p.country}');
          print('  Thoroughfare: ${p.thoroughfare}');
          print('  SubThoroughfare: ${p.subThoroughfare}');
        }
        return placemarks.first.administrativeArea; // return first city
      } else {
        print('No placemarks found.');
      }
      return null;
    } catch (e) {
      print('Error getting placemark: $e');
      return null;
    }
  }

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
