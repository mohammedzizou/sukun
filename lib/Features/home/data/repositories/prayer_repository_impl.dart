import 'package:dartz/dartz.dart';
import 'package:prayer_silence_time_app/features/home/data/datasources/home_local_calculation_data_source.dart';
import 'package:prayer_silence_time_app/features/home/data/datasources/home_local_data_source.dart';
import 'package:prayer_silence_time_app/features/home/data/models/prayer_time_model.dart';
import 'package:prayer_silence_time_app/features/home/domain/entities/prayer_time_entity.dart';
import 'package:prayer_silence_time_app/features/home/domain/repositories/prayer_repository.dart';
import 'package:prayer_silence_time_app/core/networking/faileur.dart';
import 'package:prayer_silence_time_app/core/networking/network_info.dart';

import 'package:prayer_silence_time_app/core/local_data/shared_preferences.dart';

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

  @override
  Future<Either<Faileur, DailyPrayerTimesEntity>> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    // 1. Always try local cache first (Offline-First)
    final localPrayerTimes = await localDataSource.getLastPrayerTimes();

    // If we have cached data for the same day, return it immediately to avoid UI lag
    if (localPrayerTimes != null) {
      final isSameDay =
          localPrayerTimes.date.year == date.year &&
          localPrayerTimes.date.month == date.month &&
          localPrayerTimes.date.day == date.day;

      if (isSameDay) {
        // Background update attempt (optional, or just return cached)
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

    // 2. If no valid cache, calculate new times
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
        return Right(
          _mergeWithSilenceSettings(localPrayerTimes as DailyPrayerTimesModel),
        );
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
