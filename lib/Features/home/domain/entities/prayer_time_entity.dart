import 'package:equatable/equatable.dart';

class PrayerTimeEntity extends Equatable {
  final String name;
  final String arabicName;
  final String time;
  final String iconPath;
  final bool isSilent;

  const PrayerTimeEntity({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.iconPath,
    this.isSilent = false,
  });

  @override
  List<Object?> get props => [name, arabicName, time, iconPath, isSilent];
}

class DailyPrayerTimesEntity extends Equatable {
  final DateTime date;
  final String city;
  final String country;
  final List<PrayerTimeEntity> prayers;

  const DailyPrayerTimesEntity({
    required this.date,
    required this.city,
    required this.country,
    required this.prayers,
  });

  @override
  List<Object?> get props => [date, city, country, prayers];
}
