import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/local_data/daos/prayer_times_dao.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';
import 'package:sukun/core/services/silence_service.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import 'package:flutter/widgets.dart';

@pragma('vm:entry-point')
Future<void> prayerAlarmCallback(int id, Map<String, dynamic> data) async {
  WidgetsFlutterBinding.ensureInitialized();
  dev.log("Prayer alarm triggered: $id", name: "AlarmCallback");

  try {
    await initApp();
    final appPreferences = getIt<AppPreferences>();
    final silenceService = getIt<SilenceService>();

    final prayerName = data['prayerName'] as String;
    final duration = data['duration'] as int;

    // 1. Check if silent mode is enabled for that prayer
    if (appPreferences.isPrayerSilent(prayerName)) {
      dev.log("Silent mode activated for $prayerName", name: "AlarmCallback");
      await silenceService.enableSilentMode();

      // 2. Wait for the configured silent duration
      await Future.delayed(Duration(minutes: duration));

      // 3. Restore the previous sound mode
      await silenceService.disableSilentMode();
      dev.log(
        "Silent mode restored after $duration minutes for $prayerName",
        name: "AlarmCallback",
      );
    } else {
      dev.log(
        "Silent mode disabled for $prayerName, skipping",
        name: "AlarmCallback",
      );
    }
  } catch (e) {
    dev.log("Error in prayerAlarmCallback: $e", name: "AlarmCallback");
  }
}

class AlarmSchedulerService {
  final PrayerTimesDao _prayerTimesDao;
  final AppPreferences _appPreferences;

  AlarmSchedulerService({
    required PrayerTimesDao prayerTimesDao,
    required AppPreferences appPreferences,
  }) : _prayerTimesDao = prayerTimesDao,
       _appPreferences = appPreferences;

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
  }

  Future<void> schedulePrayerAlarms() async {
    final now = DateTime.now();
    final prayerData = await _prayerTimesDao.getPrayerTimesForDate(now);

    if (prayerData == null) {
      dev.log(
        "No prayer times found for today in database",
        name: "AlarmScheduler",
      );
      return;
    }

    // Cancel previous alarms
    for (int i = 0; i < 50; i++) {
      await AndroidAlarmManager.cancel(i);
    }

    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final silenceBefore = _appPreferences.getSilenceBefore();
    final silenceAfter = _appPreferences.getSilenceAfter();
    final isFriday = now.weekday == DateTime.friday;

    for (int i = 0; i < prayers.length; i++) {
      final name = prayers[i];
      final timeStr = prayerData[name.toLowerCase()] as String;
      if (timeStr.isEmpty) continue;

      try {
        final timeFormat = DateFormat('h:mm a');
        final prayerTime = timeFormat.parse(timeStr);
        DateTime scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        ).subtract(Duration(minutes: silenceBefore));

        if (scheduledTime.isBefore(now)) continue;

        int duration = silenceBefore + silenceAfter;

        // Ramadan Tarawih Handling
        if (name == 'Isha' && _appPreferences.getRamadanEnabled()) {
          duration += _appPreferences.getTarawihSilenceDuration();
          dev.log(
            "Tarawih alarm scheduled with extended duration",
            name: "AlarmScheduler",
          );
        }

        // Friday Jomaa Handling
        if (name == 'Dhuhr' && isFriday && _appPreferences.getJumuahEnabled()) {
          // If Jomaa is enabled, we might need a separate alarm or override Dhuhr
          // The request says "Schedule a Jomaa alarm before or during the Jomaa prayer"
          // Let's use the Jomaa specific time if available, or just extend Dhuhr.
          // The existing AppPreferences has getJumuahKhutbaTime.
          final khutbaTimeStr = _appPreferences.getJumuahKhutbaTime();
          final khutbaTime = DateFormat('HH:mm').parse(khutbaTimeStr);
          scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            khutbaTime.hour,
            khutbaTime.minute,
          );
          duration = _appPreferences.getJumuahSilenceDuration();
          dev.log("Jomaa alarm scheduled for Friday", name: "AlarmScheduler");
        }

        await AndroidAlarmManager.oneShotAt(
          scheduledTime,
          i,
          prayerAlarmCallback,
          params: {'prayerName': name, 'duration': duration},
          exact: true,
          wakeup: true,
        );
        dev.log(
          "Alarms scheduled for $name at $scheduledTime",
          name: "AlarmScheduler",
        );
      } catch (e) {
        dev.log("Error scheduling alarm for $name: $e", name: "AlarmScheduler");
      }
    }
  }

  /// Handle device reboot
  Future<void> handleReboot() async {
    dev.log(
      "Device reboot detected, rescheduling alarms",
      name: "AlarmScheduler",
    );
    await schedulePrayerAlarms();
  }
}
