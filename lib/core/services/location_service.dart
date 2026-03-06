import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/app_location.dart';

class LocationService {
  Future<AppLocation> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    // Default values if geocoding fails
    String city = 'Unknown City';
    String country = 'Unknown Country';

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        city =
            placemark.administrativeArea ??
            placemark.locality ??
            placemark.subAdministrativeArea ??
            'Unknown City';
        country = placemark.country ?? 'Unknown Country';
      }
    } catch (e) {
      // Ignore geocoding errors, just use defaults
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      country: country,
    );
  }
}
