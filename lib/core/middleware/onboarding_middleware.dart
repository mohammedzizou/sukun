import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/local_data/shared_preferences.dart';

class OnboardingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    bool hasSeenOnboarding = getIt<AppPreferences>().getHasSeenOnboarding();
    if (hasSeenOnboarding) {
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}
