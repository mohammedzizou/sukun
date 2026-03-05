// ignore_for_file: non_constant_identifier_names, strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesKeys {
  static const String accessToken = 'accessToken';
  static const String tokenType = 'tokenType';
  static const String expiresIn = 'expiresIn';
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
}
