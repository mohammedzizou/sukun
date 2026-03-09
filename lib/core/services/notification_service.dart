import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:sukun/features/home/domain/entities/prayer_time_entity.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> init() async {
    if (!Platform.isIOS) return;

    tz.initializeTimeZones();

    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(iOS: iOSSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        log(
          'Notification clicked: ${details.payload}',
          name: 'NotificationService',
        );
      },
    );

    log('NotificationService initialized for iOS', name: 'NotificationService');
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (!Platform.isIOS) return;
    await _notificationsPlugin.cancelAll();
    log('All notifications cancelled', name: 'NotificationService');
  }

  /// Schedule notifications for all prayers
  Future<void> scheduleAllNotifications({
    required DailyPrayerTimesEntity dailyPrayers,
    required AppPreferences appPreferences,
  }) async {
    if (!Platform.isIOS) return;

    await cancelAllNotifications();

    final now = DateTime.now();
    final isFriday = now.weekday == DateTime.friday;
    final silenceBefore = appPreferences.getSilenceBefore();

    int notificationId = 0;

    for (var prayer in dailyPrayers.prayers) {
      if (!prayer.isSilent) continue;

      final prayerDateTime = _parsePrayerTime(prayer.time, dailyPrayers.date);
      if (prayerDateTime.isBefore(now)) continue;

      // 1. Prayer Time Notification
      await _scheduleNotification(
        id: notificationId++,
        title: 'Prayer Time',
        body:
            'It is time for ${prayer.name} prayer. Please enable Mosque Mode or switch your phone to silent.',
        scheduledTime: prayerDateTime,
        payload: 'prayer_${prayer.name}',
      );
      log(
        'Prayer notification scheduled for ${prayer.name} at $prayerDateTime',
        name: 'NotificationService',
      );

      // 2. Pre-prayer Reminder (5 minutes before)
      final reminderTime = prayerDateTime.subtract(const Duration(minutes: 5));
      if (reminderTime.isAfter(now)) {
        await _scheduleNotification(
          id: notificationId++,
          title: 'Prayer Reminder',
          body:
              '${prayer.name} prayer time is approaching. Prepare to silence your phone for the mosque.',
          scheduledTime: reminderTime,
          payload: 'reminder_${prayer.name}',
        );
        log(
          'Reminder notification scheduled for ${prayer.name} at $reminderTime',
          name: 'NotificationService',
        );
      }

      // 3. Jomaa Support
      if (isFriday &&
          prayer.name.toLowerCase() == 'dhuhr' &&
          appPreferences.getJumuahEnabled()) {
        final khutbaTimeStr = appPreferences.getJumuahKhutbaTime();
        final khutbaDateTime = _parseKhutbaTime(
          khutbaTimeStr,
          dailyPrayers.date,
        );

        if (khutbaDateTime.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId++,
            title: 'Jomaa Prayer',
            body:
                'Friday prayer is starting. Please switch your phone to silent for the mosque.',
            scheduledTime: khutbaDateTime,
            payload: 'jomaa',
          );
          log(
            'Jomaa notification scheduled at $khutbaDateTime',
            name: 'NotificationService',
          );
        }
      }

      // 4. Tarawih Support
      if (prayer.name.toLowerCase() == 'isha' &&
          appPreferences.getRamadanEnabled()) {
        // Schedule Tarawih reminder 15 minutes after Isha (simplified logic for Ramadan)
        final tarawihTime = prayerDateTime.add(const Duration(minutes: 15));
        if (tarawihTime.isAfter(now)) {
          await _scheduleNotification(
            id: notificationId++,
            title: 'Tarawih Reminder',
            body:
                'Tarawih prayer time. Please switch your phone to silent for the mosque.',
            scheduledTime: tarawihTime,
            payload: 'tarawih',
          );
          log(
            'Tarawih notification scheduled at $tarawihTime',
            name: 'NotificationService',
          );
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      scheduledDate: tzTime,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      title: title,
      body: body,

      payload: payload,
    );
  }

  DateTime _parsePrayerTime(String timeStr, DateTime date) {
    final format = DateFormat('h:mm a');
    final time = format.parse(timeStr);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _parseKhutbaTime(String timeStr, DateTime date) {
    // Expects HH:mm
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
