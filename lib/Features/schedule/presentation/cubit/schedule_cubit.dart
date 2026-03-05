import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/usecases/get_schedule_by_date.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/cubit/schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final GetScheduleByDate getScheduleUseCase;

  ScheduleCubit({required this.getScheduleUseCase})
    : super(ScheduleInitial(selectedDate: DateTime.now()));

  void selectDate(DateTime newDate) async {
    // 1. Instantly trigger loading and update the selection UI date
    emit(ScheduleLoading(selectedDate: newDate));

    try {
      // 2. Fetch specific schedule data for the selected day
      final schedule = await getScheduleUseCase.call(newDate);

      // 3. Emit the newly loaded data
      emit(ScheduleLoaded(selectedDate: newDate, schedule: schedule));
    } catch (e) {
      emit(ScheduleError(selectedDate: newDate, message: e.toString()));
    }
  }

  void toggleSilentForPrayer(int index) {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;

      // We create a new list for immutability and rebuild triggers
      final updatedPrayers = List.of(currentState.schedule.prayers);
      final prayer = updatedPrayers[index];

      updatedPrayers[index] = prayer.copyWith(isSilent: !prayer.isSilent);

      final updatedSchedule = currentState.schedule.copyWith(
        prayers: updatedPrayers,
      );

      emit(
        ScheduleLoaded(
          selectedDate: currentState.selectedDate,
          schedule: updatedSchedule,
        ),
      );
    }
  }

  void loadInitialSchedule() {
    selectDate(DateTime.now());
  }
}
