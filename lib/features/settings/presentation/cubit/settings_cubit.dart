import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local_data/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AppPreferences _appPreferences;

  SettingsCubit({required AppPreferences appPreferences})
    : _appPreferences = appPreferences,
      super(const SettingsState()) {
    loadSettings();
  }

  void loadSettings() {
    emit(
      state.copyWith(
        language: _appPreferences.getLanguage(),
        themeMode: _appPreferences.getThemeMode(),
        restoreSound: _appPreferences.getRestoreSound(),
        vibrateInstead: _appPreferences.getVibrateInstead(),
        calculationMethod: _appPreferences.getCalculationMethod(),
        // Location details are usually fetched from local storage or services
        // For now, we take them from the preferences if they exist or defaults
      ),
    );
  }

  Future<void> setLanguage(String language) async {
    await _appPreferences.setLanguage(language);
    emit(state.copyWith(language: language));
  }

  Future<void> setThemeMode(String mode) async {
    await _appPreferences.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setRestoreSound(bool restore) async {
    await _appPreferences.setRestoreSound(restore);
    emit(state.copyWith(restoreSound: restore));
  }

  Future<void> setVibrateInstead(bool vibrate) async {
    await _appPreferences.setVibrateInstead(vibrate);
    emit(state.copyWith(vibrateInstead: vibrate));
  }

  Future<void> setCalculationMethod(String method) async {
    await _appPreferences.setCalculationMethod(method);
    emit(state.copyWith(calculationMethod: method));
  }
}
