class AppLocation {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  AppLocation({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  @override
  String toString() {
    return 'AppLocation(lat: $latitude, lng: $longitude, city: $city, country: $country)';
  }
}
