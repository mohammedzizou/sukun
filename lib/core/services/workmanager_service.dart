import 'package:workmanager/workmanager.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/services/location_service.dart';
import 'package:sukun/features/home/domain/usecases/get_prayer_times_usecase.dart';
import 'package:sukun/core/local_data/daos/locations_dao.dart';
import 'package:sukun/core/local_data/daos/user_settings_dao.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';
import 'package:sukun/core/services/background_alarm_service.dart';
import 'dart:developer' as dev;

const String taskDailyLocationUpdate = "dailyLocationUpdate";
const String taskPrayerTimeCalculation = "prayerTimeCalculation";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    dev.log("WorkManager job started: $task", name: "WorkManager");

    try {
      // Initialize dependencies for background task
      await initApp();

      final locationService = getIt<LocationService>();
      final prayerUseCase = getIt<GetPrayerTimesUseCase>();
      final locationsDao = getIt<LocationsDao>();
      final userSettingsDao = getIt<UserSettingsDao>();
      final appPreferences = getIt<AppPreferences>();
      final alarmService = getIt<BackgroundAlarmService>();

      if (task == taskDailyLocationUpdate) {
        // 1. Get current coordinates
        final location = await locationService.getCurrentLocation();
        dev.log(
          "Location updated: ${location.city}, ${location.country}",
          name: "WorkManager",
        );

        // 2. Store updated location
        await locationsDao.insertLocation(
          latitude: location.latitude,
          longitude: location.longitude,
          city: location.city,
          country: location.country,
          source: 'WorkManager',
        );

        await userSettingsDao.upsertUserSettings(
          latitude: location.latitude,
          longitude: location.longitude,
          city: location.city,
          country: location.country,
        );

        // 3. Trigger recalculation
        final result = await prayerUseCase(
          GetPrayerTimesParams(
            city: location.city,
            country: location.country,
            latitude: location.latitude,
            longitude: location.longitude,
            date: DateTime.now(),
          ),
        );

        // 4. Refresh alarms
        result.fold(
          (failure) => dev.log(
            "Recalculation failed: ${failure.message}",
            name: "WorkManager",
          ),
          (prayers) async {
            dev.log(
              "Prayer times recalculated and alarms scheduled",
              name: "WorkManager",
            );
            await alarmService.schedulePrayerSilences(
              prayers.prayers,
              appPreferences: appPreferences,
            );
          },
        );
      } else if (task == taskPrayerTimeCalculation) {
        // 1. Read latest location
        final settings = await userSettingsDao.getUserSettings();
        if (settings != null) {
          final lat = settings['latitude'] as double;
          final lon = settings['longitude'] as double;
          final city = settings['city'] as String;
          final country = settings['country'] as String;

          // 2. Recalculate
          final result = await prayerUseCase(
            GetPrayerTimesParams(
              city: city,
              country: country,
              latitude: lat,
              longitude: lon,
              date: DateTime.now(),
            ),
          );

          // 3. Refresh alarms
          result.fold(
            (failure) => dev.log(
              "Calculation failed: ${failure.message}",
              name: "WorkManager",
            ),
            (prayers) async {
              dev.log(
                "Prayer times recalculated and alarms scheduled",
                name: "WorkManager",
              );
              await alarmService.schedulePrayerSilences(
                prayers.prayers,
                appPreferences: appPreferences,
              );
            },
          );
        }
      }
      return true;
    } catch (e) {
      dev.log("WorkManager error: $e", name: "WorkManager");
      return false;
    }
  });
}

class WorkManagerService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> scheduleDailyTasks() async {
    await Workmanager().registerPeriodicTask(
      "1",
      taskDailyLocationUpdate,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // Also run calculation once on app start and daily
    await Workmanager().registerOneOffTask(
      "2",
      taskPrayerTimeCalculation,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
