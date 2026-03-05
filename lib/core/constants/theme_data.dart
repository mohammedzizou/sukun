// ignore: dangling_library_doc_comments
/// This file contains the theme data for the application.
/// It defines the colors, typography, and other visual properties for the light and dark themes.
/// The [AppThemes] class provides static methods to retrieve the light and dark themes.
import 'package:flutter/material.dart';

class AppThemes {
  static const primaryColor = Color(0xFF06C671);
  static const secondaryColor = Color(0xffEBEBEB);
  static const thirdColor = Color(0xFF373737);
  static const lightGreyColor = Color(0xFF929292);
  static const lightwhiteColor = Color(0xFFF7F7F7);
  static const lightColor = Color(0xFFFFFFFF);

  static const secondarydarkColor = Color(0xff424242);
  static const darkGreyColor = Color(0xFFBDBDBD);
  static const darkColor = Color(0xFF212121);

  ///Light theme
  static ThemeData lightTheme() {
    return ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        primaryColorDark: const Color(0xfff8f9fd),
        fontFamily: 'SFPRODISPLAY',
        scaffoldBackgroundColor: lightColor,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: lightColor,
          filled: true,
          hoverColor: primaryColor,
          hintStyle: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: lightGreyColor),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: secondaryColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: secondaryColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: primaryColor, width: 1.0),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              color: Color(0xff2A3947)),
          bodyMedium: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w500, color: darkColor),
          bodySmall: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: lightGreyColor),
          titleMedium: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w500, color: darkColor),
        ),
        colorScheme: const ColorScheme.light(
            tertiary: Color(0xffF8F8F8),
            // ignore: deprecated_member_use
            background: Colors.black,
            onSurface: Color(0xff6A6A6A),
            primary: primaryColor,
            secondary: secondaryColor,
            onPrimary: lightwhiteColor,
            onSecondary: lightGreyColor,
            onPrimaryContainer: Color(0xffF9F9FF),
            onSecondaryContainer: Color.fromARGB(255, 238, 238, 238),
            surface: Color(0xFFF3F3F3),
            primaryContainer: Color(0xff939191)));
  }

  ///Dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryColorDark: const Color(0xff1C1C1C),
      fontFamily: 'SFPRODISPLAY',
      scaffoldBackgroundColor: darkColor,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkColor,
        elevation: 0,
        titleTextStyle: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontSize: 22.0, fontWeight: FontWeight.w700, color: lightColor),
          bodyMedium: TextStyle(
              fontSize: 14.0, fontWeight: FontWeight.w600, color: lightColor),
          bodySmall: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: darkGreyColor)),
      colorScheme: const ColorScheme.dark(
          tertiary: darkColor,
          // ignore: deprecated_member_use
          background: Colors.white,
          primary: primaryColor,
          secondary: secondarydarkColor,
          onSecondary: darkGreyColor,
          onSurface: darkGreyColor,
          onPrimary: secondarydarkColor,
          onPrimaryContainer: Color(0xff1C1C1C),
          onSecondaryContainer: Color(0xff424242),
          surface: darkColor,
          primaryContainer: lightColor),
      inputDecorationTheme: const InputDecorationTheme(
        fillColor: darkColor,
        filled: true,
        hoverColor: primaryColor,
        hintStyle: TextStyle(
            fontSize: 11.0, fontWeight: FontWeight.w600, color: lightGreyColor),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: secondarydarkColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: secondarydarkColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: primaryColor, width: 1.0),
        ),
      ),
    );
  }
}
