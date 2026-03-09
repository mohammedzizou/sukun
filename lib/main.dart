import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sukun/core/constants/route.dart';
import 'package:sukun/core/di/dipendency_injection.dart';
import 'package:sukun/core/services/workmanager_service.dart';
import 'package:sukun/core/services/alarm_scheduler_service.dart';
import 'package:sukun/core/util/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();

  // Schedule background maintenance tasks
  await WorkManagerService.scheduleDailyTasks();

  // Schedule initial prayer alarms
  await getIt<AlarmSchedulerService>().schedulePrayerAlarms();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Salah Silent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF4CAF50),
        scaffoldBackgroundColor: const Color(0xFF04140E),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
          surface: const Color(0xFF04140E),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoute.onboarding,
      getPages: routes,
    );
  }
}
