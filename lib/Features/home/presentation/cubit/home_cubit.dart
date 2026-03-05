import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/prayer_time_entity.dart';
import '../../domain/usecases/get_prayer_times_usecase.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DailyPrayerTimesEntity prayerTimes;
  final PrayerTimeEntity? nextPrayer;
  final Duration timeRemaining;

  const HomeLoaded({
    required this.prayerTimes,
    this.nextPrayer,
    this.timeRemaining = Duration.zero,
  });

  @override
  List<Object?> get props => [prayerTimes, nextPrayer, timeRemaining];

  HomeLoaded copyWith({
    DailyPrayerTimesEntity? prayerTimes,
    PrayerTimeEntity? nextPrayer,
    Duration? timeRemaining,
  }) {
    return HomeLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeRemaining: timeRemaining ?? this.timeRemaining,
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
  Timer? _timer;

  HomeCubit(this.getPrayerTimesUseCase) : super(HomeInitial());

  Future<void> getPrayerTimes({
    required String city,
    required String country,
    required double latitude,
    required double longitude,
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
      emit(HomeLoaded(prayerTimes: prayerTimes));
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
