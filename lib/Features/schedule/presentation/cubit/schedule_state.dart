import 'package:equatable/equatable.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/entities/prayer_schedule.dart';

abstract class ScheduleState extends Equatable {
  final DateTime selectedDate;

  const ScheduleState({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial({required super.selectedDate});
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading({required super.selectedDate});
}

class ScheduleLoaded extends ScheduleState {
  final PrayerSchedule schedule;

  const ScheduleLoaded({required super.selectedDate, required this.schedule});

  @override
  List<Object?> get props => [selectedDate, schedule];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError({required super.selectedDate, required this.message});

  @override
  List<Object?> get props => [selectedDate, message];
}
