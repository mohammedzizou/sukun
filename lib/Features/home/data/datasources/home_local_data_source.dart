import '../../../../core/local_data/daos/prayer_times_dao.dart';
import '../models/prayer_time_model.dart';
import '../../domain/entities/prayer_time_entity.dart';

abstract class HomeLocalDataSource {
  Future<void> cachePrayerTimes(DailyPrayerTimesModel prayerTimes);
  Future<DailyPrayerTimesModel?> getLastPrayerTimes();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final PrayerTimesDao prayerTimesDao;

  HomeLocalDataSourceImpl({required this.prayerTimesDao});

  @override
  Future<void> cachePrayerTimes(DailyPrayerTimesModel prayerTimes) async {
    // We need calculation method, default to 3 if unknown from here or fetch it.
    // For now, caching just saves it.

    // Find prayers by name
    String getPrayerTimeStr(String name) {
      return prayerTimes.prayers
          .firstWhere(
            (p) => p.name == name,
            orElse: () => PrayerTimeEntity(
              name: '',
              arabicName: '',
              time: '',
              iconPath: '',
              isSilent: false,
            ),
          )
          .time;
    }

    await prayerTimesDao.insertDailyPrayerTimes(
      date: prayerTimes.date,
      fajr: getPrayerTimeStr('Fajr'),
      sunrise: getPrayerTimeStr('Sunrise'),
      dhuhr: getPrayerTimeStr('Dhuhr'),
      asr: getPrayerTimeStr('Asr'),
      maghrib: getPrayerTimeStr('Maghrib'),
      isha: getPrayerTimeStr('Isha'),
      latitude: 0.0,
      longitude: 0.0,
      calculationMethod: prayerTimes.calculationMethod,
    );
  }

  @override
  Future<DailyPrayerTimesModel?> getLastPrayerTimes() async {
    final today = DateTime.now();
    final data = await prayerTimesDao.getPrayerTimesForDate(today);

    if (data != null) {
      final List<PrayerTimeEntity> prayers = [
        PrayerTimeEntity(
          name: 'Fajr',
          arabicName: 'الفجر',
          time: data['fajr'],
          iconPath: 'assest/icons/fajr_icon.svg',
        ),
        PrayerTimeEntity(
          name: 'Sunrise',
          arabicName: 'الشروق',
          time: data['sunrise'],
          iconPath: 'assest/icons/maghrib_icon.svg',
        ),
        PrayerTimeEntity(
          name: 'Dhuhr',
          arabicName: 'الظهر',
          time: data['dhuhr'],
          iconPath: 'assest/icons/dhuhr_icon.svg',
        ),
        PrayerTimeEntity(
          name: 'Asr',
          arabicName: 'العصر',
          time: data['asr'],
          iconPath: 'assest/icons/asr_icon.svg',
        ),
        PrayerTimeEntity(
          name: 'Maghrib',
          arabicName: 'المغرب',
          time: data['maghrib'],
          iconPath: 'assest/icons/maghrib_icon.svg',
        ),
        PrayerTimeEntity(
          name: 'Isha',
          arabicName: 'العشاء',
          time: data['isha'],
          iconPath: 'assest/icons/isha_icon.svg',
        ),
      ];

      return DailyPrayerTimesModel(
        date: DateTime.parse(data['date']),
        city: 'Local',
        country: 'Local',
        prayers: prayers,
        calculationMethod: data['calculation_method'] ?? 3,
      );
    }
    return null;
  }
}
