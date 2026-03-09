import 'package:adhan_dart/adhan_dart.dart';
import 'package:sukun/core/local_data/daos/prayer_adjustments_dao.dart';
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
  final PrayerAdjustmentsDao adjustmentsDao;

  HomeLocalCalculationDataSourceImpl({required this.adjustmentsDao});

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

    CalculationParameters params;
    int methodId = 3; // Default MWL

    switch (calculationMethod) {
      case 'Muslim World League':
        params = CalculationMethodParameters.muslimWorldLeague();
        methodId = 3;
        break;
      case 'Egyptian General Authority':
        params = CalculationMethodParameters.egyptian();
        methodId = 2;
        break;
      case 'University of Islamic Sciences, Karachi':
        params = CalculationMethodParameters.karachi();
        methodId = 1;
        break;
      case 'Islamic Society of North America':
        params = CalculationMethodParameters.northAmerica();
        methodId = 4;
        break;
      case 'Umm Al-Qura, Makkah':
        params = CalculationMethodParameters.ummAlQura();
        methodId = 0;
        break;
      case 'Dubai':
        params = CalculationMethodParameters.dubai();
        methodId = 5;
        break;
      case 'Qatar':
        params = CalculationMethodParameters.qatar();
        methodId = 6;
        break;
      case 'Singapore':
        params = CalculationMethodParameters.singapore();
        methodId = 7;
        break;
      default:
        params = CalculationMethodParameters.muslimWorldLeague();
        methodId = 3;
    }

    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    final Map<String, int> adjustments = await adjustmentsDao
        .getAllAdjustments();

    return DailyPrayerTimesModel.fromAdhan(
      prayerTimes,
      city,
      country,
      methodId,
      adjustments: adjustments,
    );
  }
}
