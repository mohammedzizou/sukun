import 'package:dartz/dartz.dart';
import '../../../../core/networking/faileur.dart';
import '../entities/prayer_time_entity.dart';

abstract class PrayerRepository {
  Future<Either<Faileur, DailyPrayerTimesEntity>> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required DateTime date,
  });
}
