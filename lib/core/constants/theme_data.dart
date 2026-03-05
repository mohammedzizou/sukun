import 'package:flutter/material.dart';

class AppColors {
  // Global Backgrounds
  static const Color backgroundTop = Color(0xFF0F2E23);
  static const Color backgroundBottom = Color(0xFF04140E);

  // Core Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color activeGreen = Color(0xFF2ECC71);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Active Green (2ECC71) Opacities
  static const Color activeGreen12 = Color(0x1E2ECC71);
  static const Color activeGreen15 = Color(0x262ECC71);
  static const Color activeGreen18 = Color(0x2D2ECC71);
  static const Color activeGreen20 = Color(0x332ECC71);
  static const Color activeGreen28 = Color(0x472ECC71);
  static const Color activeGreen30 = Color(0x4C2ECC71);

  // Mint / Light Green Tint (A3F7BF) Opacities
  static const Color mint07 = Color(0x11A3F7BF);
  static const Color mint10 = Color(0x19A3F7BF);
  static const Color mint15 = Color(0x26A3F7BF);
  static const Color mint35 = Color(0x59A3F7BF);
  static const Color mint45 = Color(0x72A3F7BF);
  static const Color mint50 = Color(0x7FA3F7BF);
  static const Color mint60 = Color(0x99A3F7BF);
  static const Color mint65 = Color(0xA5A3F7BF);
  static const Color mint100 = Color(0xFFA3F7BF);

  // Warning / Gold (FFC150 / FFDC82) Opacities for Permission Card
  static const Color gold05 = Color(0x0FFFC150);
  static const Color gold12 = Color(0x1EFFC150);
  static const Color gold15 = Color(0x26FFC150);
  static const Color gold18 = Color(0x2DFFC150);
  static const Color gold25 = Color(0x3FFFC150);
  static const Color gold60 = Color(0x99FFC150);
  static const Color gold80 = Color(0xCCFFC150);
  static const Color goldLight = Color(0xE5FFDC82);

  // Surface and Dark Elements
  static const Color surfaceDark = Color(0xFF153B2D);
  static const Color surfaceGradientDark = Color(0xCC0B2E22);
  static const Color textGrey = Color(0xFF8B9A93);
}

class AppThemes {
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.backgroundBottom,
      fontFamily: 'Inter',
      useMaterial3: true,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundBottom,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.mint35,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.activeGreen,
        surface: AppColors.backgroundTop,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.white),
        bodyMedium: TextStyle(color: AppColors.white),
        labelLarge: TextStyle(color: AppColors.textGrey),
      ),
    );
  }
}
