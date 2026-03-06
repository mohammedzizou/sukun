import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/intl.dart';
import '../../features/home/domain/entities/prayer_time_entity.dart';
import 'silence_service.dart';

class BackgroundAlarmService {
  static final SilenceService _silenceService = SilenceService();

  /// Must be called once during app initialization
  static Future<void> init() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }
  }

  /// Entry point for AndroidAlarmManager to mute the device
  @pragma('vm:entry-point')
  static Future<void> muteDeviceCallback() async {
    await _silenceService.setSilentMode();
  }

  /// Entry point for AndroidAlarmManager to unmute the device
  @pragma('vm:entry-point')
  static Future<void> unmuteDeviceCallback() async {
    await _silenceService.restoreNormalMode();
  }

  /// Schedules silent periods for the provided prayers
  Future<void> schedulePrayerSilences(List<PrayerTimeEntity> prayers) async {
    if (!Platform.isAndroid) return;

    final now = DateTime.now();
    final DateFormat formatter = DateFormat('h:mm a');

    // We cancel any existing alarms (using IDs 0 to 9 for mute, 10 to 19 for unmute)
    for (int i = 0; i < 20; i++) {
      await AndroidAlarmManager.cancel(i);
    }

    int alarmId = 0;
    for (var prayer in prayers) {
      if (!prayer.isSilent) continue;

      try {
        final prayerTime = formatter.parse(prayer.time);
        DateTime scheduledMuteTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        // If the time has already passed today, schedule for tomorrow
        if (scheduledMuteTime.isBefore(now)) {
          scheduledMuteTime = scheduledMuteTime.add(const Duration(days: 1));
        }

        // 1. Schedule the Mute Alarm
        await AndroidAlarmManager.oneShotAt(
          scheduledMuteTime,
          alarmId,
          muteDeviceCallback,
          exact: true,
          wakeup: true,
        );

        // 2. Schedule the Unmute Alarm (20 minutes after prayer)
        final scheduledUnmuteTime = scheduledMuteTime.add(
          const Duration(minutes: 20),
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
        // Handle parsing errors
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
}
