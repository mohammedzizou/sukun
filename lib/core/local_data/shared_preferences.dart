// ignore_for_file: non_constant_identifier_names, strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesKeys {
  static const String accessToken = 'accessToken';
  static const String tokenType = 'tokenType';
  static const String expiresIn = 'expiresIn';
  static const String hasSeenOnboarding = 'hasSeenOnboarding';
  static const String silenceBefore = 'silenceBefore';
  static const String silenceAfter = 'silenceAfter';
  static const String calculationMethod = 'calculationMethod';
  static const String jumuahEnabled = 'jumuahEnabled';
  static const String jumuahKhutbaTime = 'jumuahKhutbaTime';
  static const String jumuahSilenceDuration = 'jumuahSilenceDuration';
  static const String ramadanEnabled = 'ramadanEnabled';
  static const String tarawihSilenceDuration = 'tarawihSilenceDuration';
}

abstract class AppPreferencesInputs {
  Future<void> saveToken(String accessToken);
  Future<void> deleteToken();
}

abstract class AppPreferencesOutputs {
  getAccessToken();
  Future<int?> getExpiresIn();
}

class AppPreferences implements AppPreferencesInputs, AppPreferencesOutputs {
  SharedPreferences sharedPreferences;
  AppPreferences(this.sharedPreferences);

  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);
  @override
  Future<void> saveToken(String accessToken) async {
    await sharedPreferences.setString(
      AppPreferencesKeys.accessToken,
      "Token $accessToken",
    );
  }

  void init() {
    isPremiumNotifier.value = sharedPreferences.getBool("is_premium") ?? false;
  }

  Future<void> setPremium(bool value) async {
    await sharedPreferences.setBool("is_premium", value);
    isPremiumNotifier.value = value;
  }

  @override
  getAccessToken() {
    return sharedPreferences.getString(AppPreferencesKeys.accessToken) ?? '';
  }

  @override
  Future<int?> getExpiresIn() async {
    return sharedPreferences.getInt(AppPreferencesKeys.expiresIn);
  }

  @override
  Future<void> deleteToken() {
    return sharedPreferences.remove(AppPreferencesKeys.accessToken);
  }

  bool getHasSeenOnboarding() {
    return sharedPreferences.getBool(AppPreferencesKeys.hasSeenOnboarding) ??
        false;
  }

  Future<void> setHasSeenOnboarding() async {
    await sharedPreferences.setBool(AppPreferencesKeys.hasSeenOnboarding, true);
  }

  int getSilenceBefore() {
    return sharedPreferences.getInt(AppPreferencesKeys.silenceBefore) ?? 5;
  }

  Future<void> setSilenceBefore(int minutes) async {
    await sharedPreferences.setInt(AppPreferencesKeys.silenceBefore, minutes);
  }

  int getSilenceAfter() {
    return sharedPreferences.getInt(AppPreferencesKeys.silenceAfter) ?? 15;
  }

  Future<void> setSilenceAfter(int minutes) async {
    await sharedPreferences.setInt(AppPreferencesKeys.silenceAfter, minutes);
  }

  String getCalculationMethod() {
    return sharedPreferences.getString(AppPreferencesKeys.calculationMethod) ??
        'Muslim World League';
  }

  Future<void> setCalculationMethod(String method) async {
    await sharedPreferences.setString(
      AppPreferencesKeys.calculationMethod,
      method,
    );
  }

  bool isPrayerSilent(String prayerName) {
    return sharedPreferences.getBool('mute_${prayerName.toLowerCase()}') ??
        true; // Default to true (silence enabled)
  }

  Future<void> setPrayerSilent(String prayerName, bool silent) async {
    await sharedPreferences.setBool('mute_${prayerName.toLowerCase()}', silent);
  }

  // Jumu'ah (Friday) Settings
  bool getJumuahEnabled() {
    return sharedPreferences.getBool(AppPreferencesKeys.jumuahEnabled) ?? false;
  }

  Future<void> setJumuahEnabled(bool enabled) async {
    await sharedPreferences.setBool(AppPreferencesKeys.jumuahEnabled, enabled);
  }

  String getJumuahKhutbaTime() {
    return sharedPreferences.getString(AppPreferencesKeys.jumuahKhutbaTime) ??
        '13:30';
  }

  Future<void> setJumuahKhutbaTime(String time) async {
    await sharedPreferences.setString(
      AppPreferencesKeys.jumuahKhutbaTime,
      time,
    );
  }

  int getJumuahSilenceDuration() {
    return sharedPreferences.getInt(AppPreferencesKeys.jumuahSilenceDuration) ??
        45;
  }

  Future<void> setJumuahSilenceDuration(int minutes) async {
    await sharedPreferences.setInt(
      AppPreferencesKeys.jumuahSilenceDuration,
      minutes,
    );
  }

  // Ramadan Settings
  bool getRamadanEnabled() {
    return sharedPreferences.getBool(AppPreferencesKeys.ramadanEnabled) ??
        false;
  }

  Future<void> setRamadanEnabled(bool enabled) async {
    await sharedPreferences.setBool(AppPreferencesKeys.ramadanEnabled, enabled);
  }

  int getTarawihSilenceDuration() {
    return sharedPreferences.getInt(
          AppPreferencesKeys.tarawihSilenceDuration,
        ) ??
        90;
  }

  Future<void> setTarawihSilenceDuration(int minutes) async {
    await sharedPreferences.setInt(
      AppPreferencesKeys.tarawihSilenceDuration,
      minutes,
    );
  }
}
