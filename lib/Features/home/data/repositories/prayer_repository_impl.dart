import 'package:dartz/dartz.dart';
import 'package:sukun/features/home/data/datasources/home_local_calculation_data_source.dart';
import 'package:sukun/features/home/data/datasources/home_local_data_source.dart';
import 'package:sukun/features/home/data/models/prayer_time_model.dart';
import 'package:sukun/features/home/domain/entities/prayer_time_entity.dart';
import 'package:sukun/features/home/domain/repositories/prayer_repository.dart';
import 'package:sukun/core/networking/faileur.dart';
import 'package:sukun/core/networking/network_info.dart';

import 'package:sukun/core/local_data/shared_preferences.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final HomeLocalCalculationDataSource calculationDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final AppPreferences appPreferences;

  PrayerRepositoryImpl({
    required this.calculationDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.appPreferences,
  });

  int _getCalculationMethodId(String method) {
    switch (method) {
      case 'Muslim World League':
        return 3;
      case 'Egyptian General Authority':
        return 2;
      case 'University of Islamic Sciences, Karachi':
        return 1;
      case 'Islamic Society of North America':
        return 4;
      case 'Umm Al-Qura, Makkah':
        return 0;
      case 'Dubai':
        return 5;
      case 'Qatar':
        return 6;
      case 'Singapore':
        return 7;
      case 'France':
        return 8;
      case 'Turkey':
        return 9;
      case 'Tunisia':
        return 10;
      default:
        return 3;
    }
  }

  @override
  Future<Either<Faileur, DailyPrayerTimesEntity>> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    // 1. Try local cache
    var localPrayerTimes = await localDataSource.getLastPrayerTimes();

    if (localPrayerTimes != null) {
      final isSameDay =
          localPrayerTimes.date.year == date.year &&
          localPrayerTimes.date.month == date.month &&
          localPrayerTimes.date.day == date.day;
      final isSameLocation =
          localPrayerTimes.city == city && localPrayerTimes.country == country;
      final method = appPreferences.getCalculationMethod();
      final methodId = _getCalculationMethodId(method);
      final isSameMethod = localPrayerTimes.calculationMethod == methodId;

      if (isSameDay && isSameLocation && isSameMethod) {
        // Return cached for same day/location/method, update in background
        _updateCacheInBackground(
          city: city,
          country: country,
          latitude: latitude,
          longitude: longitude,
          date: date,
        );
        return Right(localPrayerTimes);
      }
    }

    // 2. If no valid cache OR location changed, calculate new times synchronously
    try {
      final method = appPreferences.getCalculationMethod();
      final calculatedPrayerTimes = await calculationDataSource
          .calculatePrayerTimes(
            latitude: latitude,
            longitude: longitude,
            date: date,
            city: city,
            country: country,
            calculationMethod: method,
          );
      await localDataSource.cachePrayerTimes(calculatedPrayerTimes);
      return Right(_mergeWithSilenceSettings(calculatedPrayerTimes));
    } catch (e) {
      // Fallback to local if calculation fails
      if (localPrayerTimes != null) {
        return Right(_mergeWithSilenceSettings(localPrayerTimes));
      }
      return Left(Faileur(500, e.toString()));
    }
  }

  DailyPrayerTimesEntity _mergeWithSilenceSettings(
    DailyPrayerTimesModel model,
  ) {
    final updatedPrayers = model.prayers.map((prayer) {
      return PrayerTimeEntity(
        name: prayer.name,
        arabicName: prayer.arabicName,
        time: prayer.time,
        iconPath: prayer.iconPath,
        isSilent: appPreferences.isPrayerSilent(prayer.name),
      );
    }).toList();

    return DailyPrayerTimesModel(
      date: model.date,
      city: model.city,
      country: model.country,
      prayers: updatedPrayers,
      calculationMethod: model.calculationMethod,
    );
  }

  Future<void> _updateCacheInBackground({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final method = appPreferences.getCalculationMethod();
      final calculated = await calculationDataSource.calculatePrayerTimes(
        latitude: latitude,
        longitude: longitude,
        date: date,
        city: city,
        country: country,
        calculationMethod: method,
      );
      await localDataSource.cachePrayerTimes(calculated);
    } catch (_) {
      // Background update failed, no need to throw
    }
  }
}
