import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String language;
  final String themeMode;
  final bool restoreSound;
  final bool vibrateInstead;
  final String calculationMethod;
  final bool autoDetectLocation;
  final String city;
  final String country;
  final int silenceBefore;
  final int silenceAfter;

  const SettingsState({
    this.language = 'English',
    this.themeMode = 'Dark',
    this.restoreSound = true,
    this.vibrateInstead = false,
    this.calculationMethod = 'Umm Al-Qura, Makkah',
    this.autoDetectLocation = true,
    this.city = 'Mecca',
    this.country = 'Saudi Arabia',
    this.silenceBefore = 5,
    this.silenceAfter = 15,
  });

  SettingsState copyWith({
    String? language,
    String? themeMode,
    bool? restoreSound,
    bool? vibrateInstead,
    String? calculationMethod,
    bool? autoDetectLocation,
    String? city,
    String? country,
    int? silenceBefore,
    int? silenceAfter,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      restoreSound: restoreSound ?? this.restoreSound,
      vibrateInstead: vibrateInstead ?? this.vibrateInstead,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      autoDetectLocation: autoDetectLocation ?? this.autoDetectLocation,
      city: city ?? this.city,
      country: country ?? this.country,
      silenceBefore: silenceBefore ?? this.silenceBefore,
      silenceAfter: silenceAfter ?? this.silenceAfter,
    );
  }

  @override
  List<Object?> get props => [
    language,
    themeMode,
    restoreSound,
    vibrateInstead,
    calculationMethod,
    autoDetectLocation,
    city,
    country,
    silenceBefore,
    silenceAfter,
  ];
}
