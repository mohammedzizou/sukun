part of 'home_cubit.dart';

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
  // New Silence Settings
  final int silenceBefore;
  final int silenceAfter;
  final bool jumuahEnabled;
  final String jumuahKhutbaTime;
  final int jumuahSilenceDuration;
  final bool ramadanEnabled;
  final int tarawihSilenceDuration;

  const HomeLoaded({
    required this.prayerTimes,
    this.nextPrayer,
    this.timeRemaining = Duration.zero,
    this.location,
    this.isAutoSilentEnabled = false,
    this.hasDndPermission = false,
    this.silenceBefore = 5,
    this.silenceAfter = 15,
    this.jumuahEnabled = false,
    this.jumuahKhutbaTime = '13:30',
    this.jumuahSilenceDuration = 45,
    this.ramadanEnabled = false,
    this.tarawihSilenceDuration = 90,
  });

  @override
  List<Object?> get props => [
    prayerTimes,
    nextPrayer,
    timeRemaining,
    location,
    isAutoSilentEnabled,
    hasDndPermission,
    silenceBefore,
    silenceAfter,
    jumuahEnabled,
    jumuahKhutbaTime,
    jumuahSilenceDuration,
    ramadanEnabled,
    tarawihSilenceDuration,
  ];

  HomeLoaded copyWith({
    DailyPrayerTimesEntity? prayerTimes,
    PrayerTimeEntity? nextPrayer,
    Duration? timeRemaining,
    AppLocation? location,
    bool? isAutoSilentEnabled,
    bool? hasDndPermission,
    int? silenceBefore,
    int? silenceAfter,
    bool? jumuahEnabled,
    String? jumuahKhutbaTime,
    int? jumuahSilenceDuration,
    bool? ramadanEnabled,
    int? tarawihSilenceDuration,
  }) {
    return HomeLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      location: location ?? this.location,
      isAutoSilentEnabled: isAutoSilentEnabled ?? this.isAutoSilentEnabled,
      hasDndPermission: hasDndPermission ?? this.hasDndPermission,
      silenceBefore: silenceBefore ?? this.silenceBefore,
      silenceAfter: silenceAfter ?? this.silenceAfter,
      jumuahEnabled: jumuahEnabled ?? this.jumuahEnabled,
      jumuahKhutbaTime: jumuahKhutbaTime ?? this.jumuahKhutbaTime,
      jumuahSilenceDuration:
          jumuahSilenceDuration ?? this.jumuahSilenceDuration,
      ramadanEnabled: ramadanEnabled ?? this.ramadanEnabled,
      tarawihSilenceDuration:
          tarawihSilenceDuration ?? this.tarawihSilenceDuration,
    );
  }
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
