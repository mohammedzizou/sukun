import 'prayer_time_item.dart';

class PrayerSchedule {
  final DateTime date;
  final List<PrayerTimeItem> prayers;

  const PrayerSchedule({required this.date, required this.prayers});

  PrayerSchedule copyWith({DateTime? date, List<PrayerTimeItem>? prayers}) {
    return PrayerSchedule(
      date: date ?? this.date,
      prayers: prayers ?? this.prayers,
    );
  }
}
