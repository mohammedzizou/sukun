import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sukun/core/local_data/daos/locations_dao.dart';
import 'package:sukun/core/local_data/daos/user_settings_dao.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';
import 'package:sukun/core/models/app_location.dart';
import 'package:sukun/core/services/background_alarm_service.dart';
import 'package:sukun/core/services/location_service.dart';
import 'package:sukun/core/services/silence_service.dart';
import 'package:sukun/features/home/domain/entities/prayer_time_entity.dart';
import 'package:sukun/features/home/domain/usecases/get_prayer_times_usecase.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetPrayerTimesUseCase getPrayerTimesUseCase;
  final LocationService locationService;
  final SilenceService silenceService;
  final BackgroundAlarmService backgroundAlarmService;
  final AppPreferences appPreferences;
  final LocationsDao locationsDao;
  final UserSettingsDao userSettingsDao;
  Timer? _timer;

  HomeCubit({
    required this.getPrayerTimesUseCase,
    required this.locationService,
    required this.silenceService,
    required this.backgroundAlarmService,
    required this.appPreferences,
    required this.locationsDao,
    required this.userSettingsDao,
  }) : super(HomeInitial());

  Future<void> initHome() async {
    final hasSeenOnboarding = appPreferences.getHasSeenOnboarding();
    final isFirstLaunch = !hasSeenOnboarding;

    if (isFirstLaunch) {
      emit(HomeLocationLoading());
      try {
        final location = await locationService.getCurrentLocation();

        await locationsDao.insertLocation(
          latitude: location.latitude,
          longitude: location.longitude,
          city: location.city,
          country: location.country,
        );
        await userSettingsDao.upsertUserSettings(
          latitude: location.latitude,
          longitude: location.longitude,
          city: location.city,
          country: location.country,
        );

        await appPreferences.setHasSeenOnboarding();

        await getPrayerTimes(
          city: location.city,
          country: location.country,
          latitude: location.latitude,
          longitude: location.longitude,
          location: location,
        );
      } catch (e) {
        final fallbackLocation = AppLocation(
          latitude: 21.422487,
          longitude: 39.826206,
          city: 'Mecca',
          country: 'Saudi Arabia',
        );
        await getPrayerTimes(
          city: fallbackLocation.city,
          country: fallbackLocation.country,
          latitude: fallbackLocation.latitude,
          longitude: fallbackLocation.longitude,
          location: fallbackLocation,
        );
      }
    } else {
      // Normal Launch: Fetch from DB directly, no loading state
      final lastLocationMaps = await locationsDao.getLastLocation();
      AppLocation? location;
      if (lastLocationMaps != null) {
        location = AppLocation(
          latitude: lastLocationMaps['latitude'],
          longitude: lastLocationMaps['longitude'],
          city: lastLocationMaps['city'] ?? 'Unknown',
          country: lastLocationMaps['country'] ?? 'Unknown',
        );
      } else {
        location = AppLocation(
          latitude: 21.422487,
          longitude: 39.826206,
          city: 'Mecca',
          country: 'Saudi Arabia',
        );
      }

      final result = await getPrayerTimesUseCase(
        GetPrayerTimesParams(
          city: location.city,
          country: location.country,
          latitude: location.latitude,
          longitude: location.longitude,
          date: DateTime.now(),
        ),
      );

      result.fold((failure) => emit(HomeError(failure.message)), (
        prayerTimes,
      ) async {
        final hasPermission = await silenceService.hasDndPermission();
        final hasBatteryOptimizationPermission = await silenceService
            .hasBatteryOptimizationPermission();
        final hasExactAlarmPermission = await silenceService
            .hasExactAlarmPermission();
        final hasLocationPermission = await locationService
            .hasLocationPermission();
        final loadedState = _createLoadedState(
          rawPrayerTimes: prayerTimes,
          location: location,
          hasDndPermission: hasPermission,
          hasBatteryOptimizationPermission: hasBatteryOptimizationPermission,
          hasExactAlarmPermission: hasExactAlarmPermission,
          hasLocationPermission: hasLocationPermission,
        );
        emit(loadedState);
        _updateNextPrayer(loadedState.prayerTimes);
        _startTimer();
      });

      // Background update silently
      _updateLocationInBackground(location);
    }
  }

  Future<void> _updateLocationInBackground(AppLocation cachedLocation) async {
    try {
      final newLocation = await locationService.getCurrentLocation();
      final distance = Geolocator.distanceBetween(
        cachedLocation.latitude,
        cachedLocation.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      if (distance > 3000) {
        // > 3km
        await locationsDao.insertLocation(
          latitude: newLocation.latitude,
          longitude: newLocation.longitude,
          city: newLocation.city,
          country: newLocation.country,
        );
        await userSettingsDao.upsertUserSettings(
          latitude: newLocation.latitude,
          longitude: newLocation.longitude,
          city: newLocation.city,
          country: newLocation.country,
        );

        final result = await getPrayerTimesUseCase(
          GetPrayerTimesParams(
            city: newLocation.city,
            country: newLocation.country,
            latitude: newLocation.latitude,
            longitude: newLocation.longitude,
            date: DateTime.now(),
          ),
        );

        result.fold((failure) {}, (prayerTimes) async {
          if (state is HomeLoaded) {
            final enriched = _enrichWithSilenceState(prayerTimes);
            emit(
              (state as HomeLoaded).copyWith(
                prayerTimes: enriched,
                location: newLocation,
              ),
            );
            _updateNextPrayer(enriched);
          }
        });
      }
    } catch (_) {
      // Background logic fails silently
    }
  }

  Future<void> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    AppLocation? location,
  }) async {
    // Only used for initial or forced fetches now where we want loading state
    emit(HomeLoading());
    final result = await getPrayerTimesUseCase(
      GetPrayerTimesParams(
        city: city,
        country: country,
        latitude: latitude,
        longitude: longitude,
        date: DateTime.now(),
      ),
    );

    result.fold((failure) => emit(HomeError(failure.message)), (
      prayerTimes,
    ) async {
      final hasPermission = await silenceService.hasDndPermission();
      final hasBatteryOptimizationPermission = await silenceService
          .hasBatteryOptimizationPermission();
      final hasExactAlarmPermission = await silenceService
          .hasExactAlarmPermission();
      final hasLocationPermission = await locationService
          .hasLocationPermission();
      final loadedState = _createLoadedState(
        rawPrayerTimes: prayerTimes,
        location: location,
        hasDndPermission: hasPermission,
        hasBatteryOptimizationPermission: hasBatteryOptimizationPermission,
        hasExactAlarmPermission: hasExactAlarmPermission,
        hasLocationPermission: hasLocationPermission,
      );
      emit(loadedState);
      _updateNextPrayer(loadedState.prayerTimes);
      _startTimer();
    });
  }

  Future<void> toggleAutoSilent(bool value) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    if (value) {
      final hasPermission = await silenceService.hasDndPermission();
      if (!hasPermission) {
        emit(currentState.copyWith(hasDndPermission: false));
        return;
      }

      // Force all individual prayers to silent when enabling the master switch
      for (var prayer in currentState.prayerTimes.prayers) {
        await appPreferences.setPrayerSilent(prayer.name, true);
      }

      final updatedPrayers = currentState.prayerTimes.prayers.map((p) {
        return PrayerTimeEntity(
          name: p.name,
          arabicName: p.arabicName,
          time: p.time,
          iconPath: p.iconPath,
          isSilent: true,
        );
      }).toList();

      final updatedDaily = DailyPrayerTimesEntity(
        date: currentState.prayerTimes.date,
        city: currentState.prayerTimes.city,
        country: currentState.prayerTimes.country,
        prayers: updatedPrayers,
      );

      final newState = currentState.copyWith(
        isAutoSilentEnabled: true,
        prayerTimes: updatedDaily,
      );

      emit(newState);
      await _rescheduleAlarms(newState);
    } else {
      await backgroundAlarmService.cancelAllSilences();

      // Force all individual prayers to non-silent when disabling the master switch
      for (var prayer in currentState.prayerTimes.prayers) {
        await appPreferences.setPrayerSilent(prayer.name, false);
      }

      final updatedPrayers = currentState.prayerTimes.prayers.map((p) {
        return PrayerTimeEntity(
          name: p.name,
          arabicName: p.arabicName,
          time: p.time,
          iconPath: p.iconPath,
          isSilent: false,
        );
      }).toList();

      final updatedDaily = DailyPrayerTimesEntity(
        date: currentState.prayerTimes.date,
        city: currentState.prayerTimes.city,
        country: currentState.prayerTimes.country,
        prayers: updatedPrayers,
      );

      emit(
        currentState.copyWith(
          isAutoSilentEnabled: false,
          prayerTimes: updatedDaily,
        ),
      );
    }
  }

  Future<void> requestDndPermission() async {
    await silenceService.requestDndPermission();
    await checkPermissions();
  }

  Future<void> requestBatteryOptimizationPermission() async {
    await silenceService.requestBatteryOptimizationPermission();
    await checkPermissions();
  }

  Future<void> requestExactAlarmPermission() async {
    await silenceService.requestExactAlarmPermission();
    await checkPermissions();
  }

  Future<void> requestLocationPermission() async {
    await locationService.requestLocationPermission();
    await checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (state is HomeLoaded) {
      final currentLoaded = state as HomeLoaded;
      final hasPermission = await silenceService.hasDndPermission();
      final hasBatteryOptimizationPermission = await silenceService
          .hasBatteryOptimizationPermission();
      final hasExactAlarmPermission = await silenceService
          .hasExactAlarmPermission();
      final hasLocationPermission = await locationService
          .hasLocationPermission();
      emit(
        currentLoaded.copyWith(
          hasDndPermission: hasPermission,
          hasBatteryOptimizationPermission: hasBatteryOptimizationPermission,
          hasExactAlarmPermission: hasExactAlarmPermission,
          hasLocationPermission: hasLocationPermission,
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        if (currentState.timeRemaining.inSeconds > 0) {
          emit(
            currentState.copyWith(
              timeRemaining:
                  currentState.timeRemaining - const Duration(seconds: 1),
            ),
          );
        } else {
          _updateNextPrayer(currentState.prayerTimes);
        }
      }
    });
  }

  void _updateNextPrayer(DailyPrayerTimesEntity prayerTimes) {
    if (state is! HomeLoaded) return;
    final now = DateTime.now();

    PrayerTimeEntity? next;
    Duration remaining = Duration.zero;

    final DateFormat formatter = DateFormat('h:mm a');

    for (var prayer in prayerTimes.prayers) {
      try {
        final prayerTime = formatter.parse(prayer.time);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          prayerTime.hour,
          prayerTime.minute,
        );

        if (prayerDateTime.isAfter(now)) {
          next = prayer;
          remaining = prayerDateTime.difference(now);
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (next == null && prayerTimes.prayers.isNotEmpty) {
      next = prayerTimes.prayers.first;
      try {
        final prayerTime = formatter.parse(next.time);
        final tomorrow = now.add(const Duration(days: 1));
        final nextDateTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          prayerTime.hour,
          prayerTime.minute,
        );
        remaining = nextDateTime.difference(now);
      } catch (e) {
        remaining = Duration.zero;
      }
    }

    emit(
      (state as HomeLoaded).copyWith(
        nextPrayer: next,
        timeRemaining: remaining,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  // --- Silence Settings & Enrichment ---
  DailyPrayerTimesEntity _enrichWithSilenceState(DailyPrayerTimesEntity data) {
    final enrichedPrayers = data.prayers.map((p) {
      return PrayerTimeEntity(
        name: p.name,
        arabicName: p.arabicName,
        time: p.time,
        iconPath: p.iconPath,
        isSilent: appPreferences.isPrayerSilent(p.name),
      );
    }).toList();

    return DailyPrayerTimesEntity(
      date: data.date,
      city: data.city,
      country: data.country,
      prayers: enrichedPrayers,
    );
  }

  HomeLoaded _createLoadedState({
    required DailyPrayerTimesEntity rawPrayerTimes,
    AppLocation? location,
    bool hasDndPermission = false,
    bool hasBatteryOptimizationPermission = false,
    bool hasExactAlarmPermission = false,
    bool hasLocationPermission = false,
  }) {
    return HomeLoaded(
      prayerTimes: _enrichWithSilenceState(rawPrayerTimes),
      location: location,
      hasDndPermission: hasDndPermission,
      hasBatteryOptimizationPermission: hasBatteryOptimizationPermission,
      hasExactAlarmPermission: hasExactAlarmPermission,
      hasLocationPermission: hasLocationPermission,
      silenceBefore: appPreferences.getSilenceBefore(),
      silenceAfter: appPreferences.getSilenceAfter(),
      jumuahEnabled: appPreferences.getJumuahEnabled(),
      jumuahKhutbaTime: appPreferences.getJumuahKhutbaTime(),
      jumuahSilenceDuration: appPreferences.getJumuahSilenceDuration(),
      ramadanEnabled: appPreferences.getRamadanEnabled(),
      tarawihSilenceDuration: appPreferences.getTarawihSilenceDuration(),
    );
  }

  Future<void> _rescheduleAlarms(HomeLoaded state) async {
    if (state.isAutoSilentEnabled) {
      await backgroundAlarmService.schedulePrayerSilences(
        state.prayerTimes.prayers,
        appPreferences: appPreferences,
      );
    }
  }

  void togglePrayerSilent(String prayerName) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final currentSilent = appPreferences.isPrayerSilent(prayerName);
      await appPreferences.setPrayerSilent(prayerName, !currentSilent);

      final updatedPrayers = currentState.prayerTimes.prayers.map((p) {
        if (p.name == prayerName) {
          return PrayerTimeEntity(
            name: p.name,
            arabicName: p.arabicName,
            time: p.time,
            iconPath: p.iconPath,
            isSilent: !currentSilent,
          );
        }
        return p;
      }).toList();

      final updatedDaily = DailyPrayerTimesEntity(
        date: currentState.prayerTimes.date,
        city: currentState.prayerTimes.city,
        country: currentState.prayerTimes.country,
        prayers: updatedPrayers,
      );

      final newState = currentState.copyWith(prayerTimes: updatedDaily);
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setJumuahEnabled(bool enabled) async {
    if (state is HomeLoaded) {
      await appPreferences.setJumuahEnabled(enabled);
      final newState = (state as HomeLoaded).copyWith(jumuahEnabled: enabled);
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setJumuahKhutbaTime(String time) async {
    if (state is HomeLoaded) {
      await appPreferences.setJumuahKhutbaTime(time);
      final newState = (state as HomeLoaded).copyWith(jumuahKhutbaTime: time);
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setJumuahSilenceDuration(int duration) async {
    if (state is HomeLoaded) {
      await appPreferences.setJumuahSilenceDuration(duration);
      final newState = (state as HomeLoaded).copyWith(
        jumuahSilenceDuration: duration,
      );
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setRamadanEnabled(bool enabled) async {
    if (state is HomeLoaded) {
      await appPreferences.setRamadanEnabled(enabled);
      final newState = (state as HomeLoaded).copyWith(ramadanEnabled: enabled);
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setTarawihSilenceDuration(int duration) async {
    if (state is HomeLoaded) {
      await appPreferences.setTarawihSilenceDuration(duration);
      final newState = (state as HomeLoaded).copyWith(
        tarawihSilenceDuration: duration,
      );
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setSilenceBefore(int minutes) async {
    if (state is HomeLoaded) {
      await appPreferences.setSilenceBefore(minutes);
      final newState = (state as HomeLoaded).copyWith(silenceBefore: minutes);
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }

  void setSilenceAfter(int minutes) async {
    if (state is HomeLoaded) {
      await appPreferences.setSilenceAfter(minutes);
      final newState = (state as HomeLoaded).copyWith(silenceAfter: minutes);
      emit(newState);
      await _rescheduleAlarms(newState);
    }
  }
}
