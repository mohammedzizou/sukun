

import 'package:dartz/dartz.dart';
import 'package:prayer_silence_time_app/features/home/data/datasources/home_local_calculation_data_source.dart';
import 'package:prayer_silence_time_app/features/home/data/datasources/home_local_data_source.dart';
import 'package:prayer_silence_time_app/features/home/domain/entities/prayer_time_entity.dart';
import 'package:prayer_silence_time_app/features/home/domain/repositories/prayer_repository.dart';
import 'package:prayer_silence_time_app/core/networking/faileur.dart';
import 'package:prayer_silence_time_app/core/networking/network_info.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final HomeLocalCalculationDataSource calculationDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PrayerRepositoryImpl({
    required this.calculationDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Faileur, DailyPrayerTimesEntity>> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final calculatedPrayerTimes = await calculationDataSource
          .calculatePrayerTimes(
            latitude: latitude,
            longitude: longitude,
            date: date,
            city: city,
            country: country,
          );
      await localDataSource.cachePrayerTimes(calculatedPrayerTimes);
      return Right(calculatedPrayerTimes);
    } catch (e) {
      final localPrayerTimes = await localDataSource.getLastPrayerTimes();
      if (localPrayerTimes != null) {
        return Right(localPrayerTimes);
      }
      return Left(Faileur(500, e.toString()));
    }
  }
}
