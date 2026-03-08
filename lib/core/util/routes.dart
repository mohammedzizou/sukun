/// This file contains the route configurations for the application.
/// It defines a list of [GetPage] objects that represent the different screens/pages of the app.
/// Each [GetPage] object specifies the name of the route and the corresponding page widget.
/// Additionally, some routes may have associated middlewares for handling authentication or other logic.
library;

import 'package:get/get.dart';
import 'package:sukun/features/main_navigation/presentation/screens/main_screen.dart';
import 'package:sukun/core/constants/route.dart';
import 'package:sukun/core/middleware/onboarding_middleware.dart';
import 'package:sukun/features/onboarding/presentation/screens/onboarding_screen.dart';

/// List of [GetPage] objects representing the routes of the application.
/// Each [GetPage] object specifies the name of the route and the corresponding page widget.
/// Some routes may also have associated middlewares for handling authentication or other logic.
List<GetPage> routes = [
  GetPage(
    name: AppRoute.onboarding,
    page: () => const OnboardingScreen(),
    middlewares: [OnboardingMiddleware()],
  ),
  GetPage(name: AppRoute.home, page: () => const MainScreen()),
];
