import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../../domain/usecases/get_prayer_times_usecase.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/models/app_location.dart';

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

  const HomeLoaded({
    required this.prayerTimes,
    this.nextPrayer,
    this.timeRemaining = Duration.zero,
    this.location,
  });

  @override
  List<Object?> get props => [prayerTimes, nextPrayer, timeRemaining, location];

  HomeLoaded copyWith({
    DailyPrayerTimesEntity? prayerTimes,
    PrayerTimeEntity? nextPrayer,
    Duration? timeRemaining,
    AppLocation? location,
  }) {
    return HomeLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      location: location ?? this.location,
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
  Timer? _timer;

  HomeCubit({
    required this.getPrayerTimesUseCase,
    required this.locationService,
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

    result.fold((failure) => emit(HomeError(failure.message)), (prayerTimes) {
      emit(HomeLoaded(prayerTimes: prayerTimes, location: location));
      _updateNextPrayer(prayerTimes);
      _startTimer();
    });
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
