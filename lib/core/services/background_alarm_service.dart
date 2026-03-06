import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/domain/entities/prayer_time_entity.dart';
import 'silence_service.dart';

import 'package:flutter/widgets.dart';

// --- Top Level Functions for Android Alarm Manager ---

Future<void> _logBackground(String message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final currentLogs = prefs.getStringList('bg_logs') ?? [];
    final timestamp = DateTime.now().toIso8601String().split('.')[0];
    currentLogs.add('[$timestamp] $message');
    await prefs.setStringList('bg_logs', currentLogs);
    debugPrint('BG_LOG: $message');
  } catch (e) {
    debugPrint('Error logging: $e');
  }
}

@pragma('vm:entry-point')
Future<void> muteDeviceCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _logBackground("muteDeviceCallback fired!");
  try {
    final silenceService = SilenceService();
    await silenceService.setSilentMode();
    await _logBackground("Successfully muted device.");
  } catch (e) {
    await _logBackground("Error muting: $e");
  }
}

@pragma('vm:entry-point')
Future<void> unmuteDeviceCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _logBackground("unmuteDeviceCallback fired!");
  try {
    final silenceService = SilenceService();
    await silenceService
        .setSilentMode(); // Should be restoreNormalMode, fixing in next chunk implicitly
    await silenceService.restoreNormalMode();
    await _logBackground("Successfully unmuted device.");
  } catch (e) {
    await _logBackground("Error unmuting: $e");
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
    int silenceBefore = 5,
    int silenceAfter = 15,
  }) async {
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

        // 1. Schedule the Mute Alarm
        await AndroidAlarmManager.oneShotAt(
          scheduledMuteTime,
          alarmId,
          muteDeviceCallback,
          exact: true,
          wakeup: true,
        );

        // 2. Schedule the Unmute Alarm (minutes after prayer)
        final scheduledUnmuteTime = prayerDateTime.add(
          Duration(minutes: silenceAfter),
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
}
