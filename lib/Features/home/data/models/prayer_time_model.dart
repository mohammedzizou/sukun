import 'package:intl/intl.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'dart:developer';
import '../../domain/entities/prayer_time_entity.dart';

class DailyPrayerTimesModel extends DailyPrayerTimesEntity {
  const DailyPrayerTimesModel({
    required super.date,
    required super.city,
    required super.country,
    required super.prayers,
    required this.calculationMethod,
  });
  final int calculationMethod;
  factory DailyPrayerTimesModel.fromAdhan(
    PrayerTimes prayerTimes,
    String city,
    String country,
    int method, {
    Map<String, int>? adjustments,
  }) {
    final DateFormat formatter = DateFormat('h:mm a');

    DateTime applyAdjustment(DateTime time, String name) {
      if (adjustments != null && adjustments.containsKey(name)) {
        final value = adjustments[name];
        if (value == null) {
          log(
            '[DailyPrayerTimesModel] WARNING: adjustments map contains key "$name" with null value. '
            'Raw adjustments map: $adjustments',
          );
          return time;
        }
        log(
          '[DailyPrayerTimesModel] Applying adjustment for $name: $value minutes. '
          'Original time=$time',
        );
        return time.add(Duration(minutes: value));
      }
      log(
        '[DailyPrayerTimesModel] No adjustment for $name. '
        'adjustments map: ${adjustments ?? '{}'}',
      );
      return time;
    }

    final List<PrayerTimeEntity> prayers = [
      PrayerTimeEntity(
        name: 'Fajr',
        arabicName: 'الفجر',
        time: formatter.format(
          applyAdjustment(prayerTimes.fajr, 'Fajr').toLocal(),
        ),
        iconPath: 'assest/icons/fajr_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Sunrise',
        arabicName: 'الشروق',
        time: formatter.format(
          applyAdjustment(prayerTimes.sunrise, 'Sunrise').toLocal(),
        ),
        iconPath: 'assest/icons/maghrib_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Dhuhr',
        arabicName: 'الظهر',
        time: formatter.format(
          applyAdjustment(prayerTimes.dhuhr, 'Dhuhr').toLocal(),
        ),
        iconPath: 'assest/icons/dhuhr_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Asr',
        arabicName: 'العصر',
        time: formatter.format(
          applyAdjustment(prayerTimes.asr, 'Asr').toLocal(),
        ),
        iconPath: 'assest/icons/asr_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Maghrib',
        arabicName: 'المغرب',
        time: formatter.format(
          applyAdjustment(prayerTimes.maghrib, 'Maghrib').toLocal(),
        ),
        iconPath: 'assest/icons/maghrib_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Isha',
        arabicName: 'العشاء',
        time: formatter.format(
          applyAdjustment(prayerTimes.isha, 'Isha').toLocal(),
        ),
        iconPath: 'assest/icons/isha_icon.svg',
      ),
    ];

    return DailyPrayerTimesModel(
      date: prayerTimes.date,
      city: city,
      country: country,
      prayers: prayers,
      calculationMethod: method,
    );
  }

  factory DailyPrayerTimesModel.fromJson(
    Map<String, dynamic> json,
    String city,
    String country,
    int method,
  ) {
    final timings = json['timings'] as Map<String, dynamic>;

    // Convert timings map to list of PrayerTimeEntity
    final List<PrayerTimeEntity> prayers = [
      PrayerTimeEntity(
        name: 'Fajr',
        arabicName: 'الفجر',
        time: timings['Fajr'],
        iconPath: 'assest/icons/fajr_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Dhuhr',
        arabicName: 'الظهر',
        time: timings['Dhuhr'],
        iconPath: 'assest/icons/dhuhr_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Asr',
        arabicName: 'العصر',
        time: timings['Asr'],
        iconPath: 'assest/icons/asr_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Maghrib',
        arabicName: 'المغرب',
        time: timings['Maghrib'],
        iconPath: 'assest/icons/maghrib_icon.svg',
      ),
      PrayerTimeEntity(
        name: 'Isha',
        arabicName: 'العشاء',
        time: timings['Isha'],
        iconPath: 'assest/icons/isha_icon.svg',
      ),
    ];

    return DailyPrayerTimesModel(
      date: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['date']['timestamp']) * 1000,
      ),
      city: city,
      country: country,
      prayers: prayers,
      calculationMethod: method,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'timestamp': date.millisecondsSinceEpoch ~/ 1000,
      'calculation_method': calculationMethod,
      'prayers': prayers
          .map(
            (p) => {
              'name': p.name,
              'arabicName': p.arabicName,
              'time': p.time,
              'iconPath': p.iconPath,
              'isSilent': p.isSilent,
            },
          )
          .toList(),
    };
  }

  factory DailyPrayerTimesModel.fromLocalJson(Map<String, dynamic> json) {
    return DailyPrayerTimesModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000),
      city: json['city'],
      country: json['country'],
      calculationMethod: json['calculation_method'] ?? 3,
      prayers: (json['prayers'] as List)
          .map(
            (p) => PrayerTimeEntity(
              name: p['name'],
              arabicName: p['arabicName'],
              time: p['time'],
              iconPath: p['iconPath'],
              isSilent: p['isSilent'] ?? false,
            ),
          )
          .toList(),
    );
  }
}
