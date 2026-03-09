import 'package:equatable/equatable.dart';
import '../../../../home/domain/entities/prayer_time_entity.dart';

class PrayerAdjustmentsState extends Equatable {
  final List<PrayerTimeEntity> prayers;
  final Map<String, int> adjustments;
  final bool isLoading;
  final String? error;

  const PrayerAdjustmentsState({
    this.prayers = const [],
    this.adjustments = const {},
    this.isLoading = false,
    this.error,
  });

  PrayerAdjustmentsState copyWith({
    List<PrayerTimeEntity>? prayers,
    Map<String, int>? adjustments,
    bool? isLoading,
    String? error,
  }) {
    return PrayerAdjustmentsState(
      prayers: prayers ?? this.prayers,
      adjustments: adjustments ?? this.adjustments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [prayers, adjustments, isLoading, error];
}
