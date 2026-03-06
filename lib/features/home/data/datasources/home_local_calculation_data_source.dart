import 'package:adhan_dart/adhan_dart.dart';
import '../models/prayer_time_model.dart';

abstract class HomeLocalCalculationDataSource {
  Future<DailyPrayerTimesModel> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String city,
    required String country,
    required String calculationMethod,
  });
}

class HomeLocalCalculationDataSourceImpl
    implements HomeLocalCalculationDataSource {
  @override
  Future<DailyPrayerTimesModel> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String city,
    required String country,
    required String calculationMethod,
  }) async {
    final coordinates = Coordinates(latitude, longitude);

    // Defaulting to Muslim World League (MWL) as it's commonly used in Algeria
    // In the future, this can be retrieved from settings
    final params = CalculationMethodParameters.muslimWorldLeague();

    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    return DailyPrayerTimesModel.fromAdhan(prayerTimes, city, country);
  }
}
