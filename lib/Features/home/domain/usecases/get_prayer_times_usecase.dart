import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/networking/faileur.dart';
import '../../../../core/use_case/use_case.dart';
import '../entities/prayer_time_entity.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTimesUseCase
    extends UseCase<DailyPrayerTimesEntity, GetPrayerTimesParams> {
  final PrayerRepository repository;

  GetPrayerTimesUseCase(this.repository);

  @override
  Future<Either<Faileur, DailyPrayerTimesEntity>> call([
    GetPrayerTimesParams? params,
  ]) async {
    return await repository.getPrayerTimes(
      city: params!.city,
      country: params.country,
      latitude: params.latitude,
      longitude: params.longitude,
      date: params.date,
    );
  }
}

class GetPrayerTimesParams extends Equatable {
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final DateTime date;

  const GetPrayerTimesParams({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  @override
  List<Object?> get props => [city, country, latitude, longitude, date];
}
