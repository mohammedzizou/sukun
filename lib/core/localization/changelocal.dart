import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../util/myservises.dart';

List<String> languages = [
  "bg",
  "cs",
  "da",
  "nl",
  "en",
  "et",
  "fi",
  "fr",
  "de",
  "el",
  "hu",
  "it",
  "no",
  "pl",
  "pt",
  "ro",
  "ru",
  "sk",
  "es",
  "sv",
  "tr",
  "uk"
];

/// A controller for changing the language of the app.
class LocaleController extends GetxController {
  Locale? language;
  MyServices myServices = Get.find();

  /// Changes the language of the app to the specified [langcode].
  /// Updates the locale and saves the language preference in shared preferences.
  void changeLang(String langcode) {
    Locale locale = Locale(langcode);
    myServices.sharedPreferences.setString("lang", langcode);
    Get.updateLocale(locale);
  }

  @override
  void onInit() {
    String? sharedPrefLang = myServices.sharedPreferences.getString("lang");
    if (sharedPrefLang != null && sharedPrefLang.isNotEmpty) {
      language = Locale(sharedPrefLang);
    } else {
      myServices.sharedPreferences.setString("lang", getDeviceLanguage());
      language = Locale(getDeviceLanguage());
    }
    super.onInit();
  }
  String getDeviceLanguage() {
    final locale = Get.deviceLocale;
    final languageCode = locale?.languageCode.toLowerCase() ?? 'en';
    return languages.contains(languageCode) ? languageCode : 'en';
  }
}
