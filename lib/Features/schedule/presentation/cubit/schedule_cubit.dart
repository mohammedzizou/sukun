import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prayer_silence_time_app/core/local_data/shared_preferences.dart';
import 'package:prayer_silence_time_app/features/schedule/domain/entities/prayer_time_item.dart';
import 'package:prayer_silence_time_app/features/schedule/presentation/cubit/schedule_state.dart';
import 'package:prayer_silence_time_app/core/constants/images.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final AppPreferences appPreferences;

  ScheduleCubit({required this.appPreferences})
    : super(const ScheduleInitial());

  void loadInitialSchedule() {
    emit(const ScheduleLoading());

    try {
      final prayers = [
        _getPrayerItem('Fajr', AppIcons.fajr, '5:12 AM'),
        _getPrayerItem('Dhuhr', AppIcons.dhuhr, '12:28 PM'),
        _getPrayerItem('Asr', AppIcons.asr, '3:45 PM'),
        _getPrayerItem('Maghrib', AppIcons.maghrib, '6:22 PM'),
        _getPrayerItem('Isha', AppIcons.isha, '7:52 PM'),
      ];

      emit(
        ScheduleLoaded(
          prayers: prayers,
          jumuahEnabled: appPreferences.getJumuahEnabled(),
          jumuahKhutbaTime: appPreferences.getJumuahKhutbaTime(),
          jumuahSilenceDuration: appPreferences.getJumuahSilenceDuration(),
          ramadanEnabled: appPreferences.getRamadanEnabled(),
          tarawihSilenceDuration: appPreferences.getTarawihSilenceDuration(),
          silenceBefore: appPreferences.getSilenceBefore(),
          silenceAfter: appPreferences.getSilenceAfter(),
        ),
      );
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  PrayerTimeItem _getPrayerItem(String name, String icon, String defaultTime) {
    return PrayerTimeItem(
      name: name,
      time:
          defaultTime, // Note: In a real app, this might come from the same calculation source
      iconPath: icon,
      isSilent: appPreferences.isPrayerSilent(name),
    );
  }

  void toggleSilentForPrayer(int index) async {
    if (state is ScheduleLoaded) {
      final currentState = state as ScheduleLoaded;
      final prayer = currentState.prayers[index];
      final newSilent = !prayer.isSilent;

      await appPreferences.setPrayerSilent(prayer.name, newSilent);

      final updatedPrayers = List<PrayerTimeItem>.from(currentState.prayers);
      updatedPrayers[index] = prayer.copyWith(isSilent: newSilent);

      emit(currentState.copyWith(prayers: updatedPrayers));
    }
  }

  void setJumuahEnabled(bool enabled) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setJumuahEnabled(enabled);
      emit((state as ScheduleLoaded).copyWith(jumuahEnabled: enabled));
    }
  }

  void setJumuahKhutbaTime(String time) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setJumuahKhutbaTime(time);
      emit((state as ScheduleLoaded).copyWith(jumuahKhutbaTime: time));
    }
  }

  void setJumuahSilenceDuration(int duration) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setJumuahSilenceDuration(duration);
      emit((state as ScheduleLoaded).copyWith(jumuahSilenceDuration: duration));
    }
  }

  void setRamadanEnabled(bool enabled) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setRamadanEnabled(enabled);
      emit((state as ScheduleLoaded).copyWith(ramadanEnabled: enabled));
    }
  }

  void setTarawihSilenceDuration(int duration) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setTarawihSilenceDuration(duration);
      emit(
        (state as ScheduleLoaded).copyWith(tarawihSilenceDuration: duration),
      );
    }
  }

  void setSilenceBefore(int minutes) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setSilenceBefore(minutes);
      emit((state as ScheduleLoaded).copyWith(silenceBefore: minutes));
    }
  }

  void setSilenceAfter(int minutes) async {
    if (state is ScheduleLoaded) {
      await appPreferences.setSilenceAfter(minutes);
      emit((state as ScheduleLoaded).copyWith(silenceAfter: minutes));
    }
  }
}
