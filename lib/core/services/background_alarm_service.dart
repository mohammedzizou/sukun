import 'dart:developer';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/intl.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/domain/entities/prayer_time_entity.dart';
import '../local_data/daos/silent_logs_dao.dart';
import '../local_data/daos/prayer_times_dao.dart';
import 'silence_service.dart';
import 'dart:developer' as dev;
import 'package:flutter/widgets.dart';

@pragma('vm:entry-point')
Future<void> muteDeviceCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  log("muteDeviceCallback fired!");
  try {
    final prefs = await SharedPreferences.getInstance();
    final appPrefs = AppPreferences(prefs);
    final vibrateInstead = appPrefs.getVibrateInstead();

    final silenceService = SilenceService();
    await silenceService.setSilentMode(vibrate: vibrateInstead);
    log(
      vibrateInstead
          ? "Successfully set device to vibrate."
          : "Successfully muted device.",
    );

    // Log to DB
    final logsDao = SilentLogsDao();
    logsDao.logSilentEvent(
      date: DateTime.now(),
      prayerName: 'Scheduled Event',
      actualStart: DateTime.now(),
      triggerType: vibrateInstead ? 'scheduled_vibrate' : 'scheduled_mute',
      status: 'success',
    );
  } catch (e) {
    log("Error muting: $e");
  }
}

@pragma('vm:entry-point')
Future<void> unmuteDeviceCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  log("unmuteDeviceCallback fired!");
  try {
    final prefs = await SharedPreferences.getInstance();
    final appPrefs = AppPreferences(prefs);
    final restoreSound = appPrefs.getRestoreSound();

    if (restoreSound) {
      final silenceService = SilenceService();
      await silenceService.restoreNormalMode();
      log("Successfully restored normal mode.");
    } else {
      log("Skipping sound restoration as per settings.");
    }

    // Log to DB
    final logsDao = SilentLogsDao();
    logsDao.logSilentEvent(
      date: DateTime.now(),
      prayerName: 'Scheduled Event',
      actualStart: DateTime.now(),
      triggerType: 'scheduled_unmute',
      status: 'success',
    );
  } catch (e) {
    log("Error unmuting: $e");
  }
}

// -----------------------------------------------------

class BackgroundAlarmService {
  static final SilenceService _silenceService = SilenceService();

  /// Must be called once during app initialization
  /// Must be called once during app initialization
  static Future<void> init() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }
  }

  /// Schedules silent periods for the provided prayers
  Future<void> schedulePrayerSilences(
    List<PrayerTimeEntity> prayers, {
    required AppPreferences appPreferences,
  }) async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();
    final DateFormat formatter = DateFormat('h:mm a');
    final silenceBefore = appPreferences.getSilenceBefore();
    final silenceAfter = appPreferences.getSilenceAfter();

    // We cancel any existing alarms (using IDs 0 to 29 for more space)
    for (int i = 0; i < 30; i++) {
      await AndroidAlarmManager.cancel(i);
    }

    int alarmId = 0;
    bool isFriday = now.weekday == DateTime.friday;

    for (var prayer in prayers) {
      // 1. Handle Jumu'ah override for Dhuhr
      if (isFriday &&
          appPreferences.getJumuahEnabled() &&
          prayer.name.toLowerCase() == 'dhuhr') {
        log("Scheduling Jumu'ah Khutba override for Dhuhr");
        try {
          final khutbaTimeStr = appPreferences.getJumuahKhutbaTime();
          final khutbaTime = DateFormat('HH:mm').parse(khutbaTimeStr);
          DateTime khutbaDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            khutbaTime.hour,
            khutbaTime.minute,
          );

          if (khutbaDateTime.isBefore(now)) {
            khutbaDateTime = khutbaDateTime.add(const Duration(days: 1));
          }

          // Schedule Khutba Mute
          await AndroidAlarmManager.oneShotAt(
            khutbaDateTime,
            alarmId,
            muteDeviceCallback,
            exact: true,
            wakeup: true,
          );

          // Schedule Khutba Unmute
          final khutbaUnmuteTime = khutbaDateTime.add(
            Duration(minutes: appPreferences.getJumuahSilenceDuration()),
          );
          await AndroidAlarmManager.oneShotAt(
            khutbaUnmuteTime,
            alarmId + 10,
            unmuteDeviceCallback,
            exact: true,
            wakeup: true,
          );

          alarmId++;
          continue; // Skip normal Dhuhr
        } catch (e) {
          log("Error scheduling Jumu'ah: $e");
        }
      }

      if (!prayer.isSilent) continue;

      try {
        final prayerTime = formatter.parse(prayer.time);
        DateTime prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        // Calculate mute time with "before" offset
        DateTime scheduledMuteTime = prayerDateTime.subtract(
          Duration(minutes: silenceBefore),
        );

        // If the time has already passed today, schedule for tomorrow
        if (scheduledMuteTime.isBefore(now)) {
          scheduledMuteTime = scheduledMuteTime.add(const Duration(days: 1));
          prayerDateTime = prayerDateTime.add(const Duration(days: 1));
        }

        // 2. Handle Ramadan override for Isha (Tarawih)
        int currentSilenceAfter = silenceAfter;
        if (appPreferences.getRamadanEnabled() &&
            prayer.name.toLowerCase() == 'isha') {
          currentSilenceAfter += appPreferences.getTarawihSilenceDuration();
          log("Extended Isha silence for Tarawih: $currentSilenceAfter min");
        }

        // 1. Schedule the Mute Alarm
        await AndroidAlarmManager.oneShotAt(
          scheduledMuteTime,
          alarmId,
          muteDeviceCallback,
          exact: true,
          wakeup: true,
        );

        // 2. Schedule the Unmute Alarm
        final scheduledUnmuteTime = prayerDateTime.add(
          Duration(minutes: currentSilenceAfter),
        );
        await AndroidAlarmManager.oneShotAt(
          scheduledUnmuteTime,
          alarmId + 10,
          unmuteDeviceCallback,
          exact: true,
          wakeup: true,
        );

        alarmId++;
      } catch (e) {
        log("Error scheduling prayer $prayer: $e");
      }
    }
  }

  /// Cancels all scheduled prayer silences
  Future<void> cancelAllSilences() async {
    if (!Platform.isAndroid) return;
    for (int i = 0; i < 20; i++) {
      await AndroidAlarmManager.cancel(i);
    }
    // Eagerly restore normal mode in case we are currently in a silenced period
    await _silenceService.restoreNormalMode();
  }

  /// Schedules a test silence that starts in 15 seconds and lasts for 15 seconds
  Future<void> testSilenceScheduling() async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();
    final muteTime = now.add(const Duration(seconds: 15));
    final unmuteTime = muteTime.add(const Duration(seconds: 15));

    // Cancel existing alarms for tests (use ID 998 and 999 for tests)
    await AndroidAlarmManager.cancel(998);
    await AndroidAlarmManager.cancel(999);

    // Schedule Mute
    await AndroidAlarmManager.oneShotAt(
      muteTime,
      998,
      muteDeviceCallback,
      exact: true,
      wakeup: true,
    );

    // Schedule Unmute
    await AndroidAlarmManager.oneShotAt(
      unmuteTime,
      999,
      unmuteDeviceCallback,
      exact: true,
      wakeup: true,
    );
  }

  /// Fetches prayer times from DB and schedules alarms
  Future<void> scheduleDailyAlarmsFromDb({
    required PrayerTimesDao prayerTimesDao,
    required AppPreferences appPreferences,
  }) async {
    final now = DateTime.now();
    final prayerData = await prayerTimesDao.getPrayerTimesForDate(now);

    if (prayerData == null) {
      dev.log("No prayer times in DB for $now", name: "BackgroundAlarm");
      return;
    }

    // Convert DB map to entities
    final prayers = <PrayerTimeEntity>[
      PrayerTimeEntity(
        name: 'Fajr',
        arabicName: 'الفجر',
        time: prayerData['fajr'],
        iconPath: '',
        isSilent: appPreferences.isPrayerSilent('Fajr'),
      ),
      PrayerTimeEntity(
        name: 'Dhuhr',
        arabicName: 'الظهر',
        time: prayerData['dhuhr'],
        iconPath: '',
        isSilent: appPreferences.isPrayerSilent('Dhuhr'),
      ),
      PrayerTimeEntity(
        name: 'Asr',
        arabicName: 'العصر',
        time: prayerData['asr'],
        iconPath: '',
        isSilent: appPreferences.isPrayerSilent('Asr'),
      ),
      PrayerTimeEntity(
        name: 'Maghrib',
        arabicName: 'المغرب',
        time: prayerData['maghrib'],
        iconPath: '',
        isSilent: appPreferences.isPrayerSilent('Maghrib'),
      ),
      PrayerTimeEntity(
        name: 'Isha',
        arabicName: 'العشاء',
        time: prayerData['isha'],
        iconPath: '',
        isSilent: appPreferences.isPrayerSilent('Isha'),
      ),
    ];

    await schedulePrayerSilences(prayers, appPreferences: appPreferences);
  }
}
