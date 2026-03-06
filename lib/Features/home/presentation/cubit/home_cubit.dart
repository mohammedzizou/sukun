import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:prayer_silence_time_app/core/local_data/shared_preferences.dart';
import 'package:prayer_silence_time_app/core/models/app_location.dart';
import 'package:prayer_silence_time_app/core/services/background_alarm_service.dart';
import 'package:prayer_silence_time_app/core/services/location_service.dart';
import 'package:prayer_silence_time_app/core/services/silence_service.dart';
import 'package:prayer_silence_time_app/features/home/domain/entities/prayer_time_entity.dart';
import 'package:prayer_silence_time_app/features/home/domain/usecases/get_prayer_times_usecase.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLocationLoading extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DailyPrayerTimesEntity prayerTimes;
  final PrayerTimeEntity? nextPrayer;
  final Duration timeRemaining;
  final AppLocation? location;
  final bool isAutoSilentEnabled;
  final bool hasDndPermission;

  const HomeLoaded({
    required this.prayerTimes,
    this.nextPrayer,
    this.timeRemaining = Duration.zero,
    this.location,
    this.isAutoSilentEnabled = false,
    this.hasDndPermission = false,
  });

  @override
  List<Object?> get props => [
    prayerTimes,
    nextPrayer,
    timeRemaining,
    location,
    isAutoSilentEnabled,
    hasDndPermission,
  ];

  HomeLoaded copyWith({
    DailyPrayerTimesEntity? prayerTimes,
    PrayerTimeEntity? nextPrayer,
    Duration? timeRemaining,
    AppLocation? location,
    bool? isAutoSilentEnabled,
    bool? hasDndPermission,
  }) {
    return HomeLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      location: location ?? this.location,
      isAutoSilentEnabled: isAutoSilentEnabled ?? this.isAutoSilentEnabled,
      hasDndPermission: hasDndPermission ?? this.hasDndPermission,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeCubit extends Cubit<HomeState> {
  final GetPrayerTimesUseCase getPrayerTimesUseCase;
  final LocationService locationService;
  final SilenceService silenceService;
  final BackgroundAlarmService backgroundAlarmService;
  final AppPreferences appPreferences;
  Timer? _timer;

  HomeCubit({
    required this.getPrayerTimesUseCase,
    required this.locationService,
    required this.silenceService,
    required this.backgroundAlarmService,
    required this.appPreferences,
  }) : super(HomeInitial());

  Future<void> initHome() async {
    emit(HomeLocationLoading());
    try {
      final location = await locationService.getCurrentLocation();
      await getPrayerTimes(
        city: location.city,
        country: location.country,
        latitude: location.latitude,
        longitude: location.longitude,
        location: location,
      );
    } catch (e) {
      // Fallback location if permission denied or error occurs
      final fallbackLocation = AppLocation(
        latitude: 21.422487, // Mecca
        longitude: 39.826206,
        city: 'Mecca',
        country: 'Saudi Arabia',
      );
      // We can emit an error first, or just proceed with fallback.
      // For now, let's proceed with fallback so the app still works.
      await getPrayerTimes(
        city: fallbackLocation.city,
        country: fallbackLocation.country,
        latitude: fallbackLocation.latitude,
        longitude: fallbackLocation.longitude,
        location: fallbackLocation,
      );
    }
  }

  Future<void> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    AppLocation? location,
  }) async {
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
      emit(
        HomeLoaded(
          prayerTimes: prayerTimes,
          location: location,
          hasDndPermission: hasPermission,
        ),
      );
      _updateNextPrayer(prayerTimes);
      _startTimer();
    });
  }

  Future<void> toggleAutoSilent(bool value) async {
    if (state is! HomeLoaded) return;
    final currentState = state as HomeLoaded;

    if (value) {
      final hasPermission = await silenceService.hasDndPermission();
      if (!hasPermission) {
        // Cannot enable without permission (will show banner on Android)
        emit(currentState.copyWith(hasDndPermission: false));
        return;
      }
      // Re-schedule alarms
      await backgroundAlarmService.schedulePrayerSilences(
        currentState.prayerTimes.prayers,
        silenceBefore: appPreferences.getSilenceBefore(),
        silenceAfter: appPreferences.getSilenceAfter(),
      );
      emit(currentState.copyWith(isAutoSilentEnabled: true));
    } else {
      // Cancel alarms
      await backgroundAlarmService.cancelAllSilences();
      emit(currentState.copyWith(isAutoSilentEnabled: false));
    }
  }

  Future<void> requestDndPermission() async {
    await silenceService.requestDndPermission();
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(hasDndPermission: true));
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
          // Re-calculate next prayer if time reached zero
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
        // Fallback for non-standard formats if any
        continue;
      }
    }

    // If no next prayer today, the next one is Fajr tomorrow
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
}
