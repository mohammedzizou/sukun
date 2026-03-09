import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/local_data/daos/locations_dao.dart';
import 'package:sukun/core/local_data/daos/user_settings_dao.dart';
import 'package:sukun/features/home/presentation/controller/cubit/home_cubit.dart';
import '../../../../core/local_data/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final AppPreferences _appPreferences;
  final LocationsDao _locationsDao;
  final UserSettingsDao _userSettingsDao;

  SettingsCubit({
    required AppPreferences appPreferences,
    required LocationsDao locationsDao,
    required UserSettingsDao userSettingsDao,
  }) : _appPreferences = appPreferences,
       _locationsDao = locationsDao,
       _userSettingsDao = userSettingsDao,
       super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final lastLocation = await _locationsDao.getLastLocation();
    final userSettings = await _userSettingsDao.getUserSettings();

    emit(
      state.copyWith(
        language: _appPreferences.getLanguage(),
        themeMode: _appPreferences.getThemeMode(),
        restoreSound: _appPreferences.getRestoreSound(),
        vibrateInstead: _appPreferences.getVibrateInstead(),
        calculationMethod: _appPreferences.getCalculationMethod(),
        city: lastLocation?['city'] ?? 'Mecca',
        country: lastLocation?['country'] ?? 'Saudi Arabia',
        autoDetectLocation: (userSettings?['auto_location'] ?? 1) == 1,
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
    _triggerHomeRefresh();
  }

  Future<void> setVibrateInstead(bool vibrate) async {
    await _appPreferences.setVibrateInstead(vibrate);
    emit(state.copyWith(vibrateInstead: vibrate));
    _triggerHomeRefresh();
  }

  void _triggerHomeRefresh() {
    if (getIt.isRegistered<HomeCubit>()) {
      getIt<HomeCubit>().refreshHome();
    }
  }

  Future<void> setCalculationMethod(String method) async {
    await _appPreferences.setCalculationMethod(method);
    emit(state.copyWith(calculationMethod: method));
    _triggerHomeRefresh();
  }
}
