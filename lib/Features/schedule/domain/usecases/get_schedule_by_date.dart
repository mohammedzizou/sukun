import 'package:prayer_silence_time_app/features/schedule/domain/entities/prayer_schedule.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/entities/prayer_time_item.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';

class GetScheduleByDate {
  // Mock Data generation to simulate fetching from a local/remote source
  Future<PrayerSchedule> call(DateTime date) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate some mock variations based on the day to prove reactivity
    final bool isEvenDay = date.day % 2 == 0;

    return PrayerSchedule(
      date: date,
      prayers: [
        PrayerTimeItem(
          name: 'Fajr',
          time: '5:12 AM',
          iconPath: AppIcons.fajr,
          isSilent: isEvenDay, // Toggle varies by day
        ),
        PrayerTimeItem(
          name: 'Dhuhr',
          time: '12:28 PM',
          iconPath: AppIcons.dhuhr,
          isSilent: !isEvenDay,
        ),
        PrayerTimeItem(
          name: 'Asr',
          time: '3:45 PM',
          iconPath: AppIcons.asr,
          isSilent: isEvenDay,
        ),
        PrayerTimeItem(
          name: 'Maghrib',
          time: '6:22 PM',
          iconPath: AppIcons.maghrib,
          isSilent: true,
        ),
        PrayerTimeItem(
          name: 'Isha',
          time: '7:52 PM',
          iconPath: AppIcons.isha,
          isSilent: false,
        ),
      ],
    );
  }
}
