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
}
