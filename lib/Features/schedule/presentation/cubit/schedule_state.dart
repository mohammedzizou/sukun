import 'package:equatable/equatable.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/entities/prayer_time_item.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final List<PrayerTimeItem> prayers;
  final bool jumuahEnabled;
  final String jumuahKhutbaTime;
  final int jumuahSilenceDuration;
  final bool ramadanEnabled;
  final int tarawihSilenceDuration;
  final int silenceBefore;
  final int silenceAfter;

  const ScheduleLoaded({
    required this.prayers,
    required this.jumuahEnabled,
    required this.jumuahKhutbaTime,
    required this.jumuahSilenceDuration,
    required this.ramadanEnabled,
    required this.tarawihSilenceDuration,
    required this.silenceBefore,
    required this.silenceAfter,
  });

  @override
  List<Object?> get props => [
    prayers,
    jumuahEnabled,
    jumuahKhutbaTime,
    jumuahSilenceDuration,
    ramadanEnabled,
    tarawihSilenceDuration,
    silenceBefore,
    silenceAfter,
  ];

  ScheduleLoaded copyWith({
    List<PrayerTimeItem>? prayers,
    bool? jumuahEnabled,
    String? jumuahKhutbaTime,
    int? jumuahSilenceDuration,
    bool? ramadanEnabled,
    int? tarawihSilenceDuration,
    int? silenceBefore,
    int? silenceAfter,
  }) {
    return ScheduleLoaded(
      prayers: prayers ?? this.prayers,
      jumuahEnabled: jumuahEnabled ?? this.jumuahEnabled,
      jumuahKhutbaTime: jumuahKhutbaTime ?? this.jumuahKhutbaTime,
      jumuahSilenceDuration:
          jumuahSilenceDuration ?? this.jumuahSilenceDuration,
      ramadanEnabled: ramadanEnabled ?? this.ramadanEnabled,
      tarawihSilenceDuration:
          tarawihSilenceDuration ?? this.tarawihSilenceDuration,
      silenceBefore: silenceBefore ?? this.silenceBefore,
      silenceAfter: silenceAfter ?? this.silenceAfter,
    );
  }
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}
