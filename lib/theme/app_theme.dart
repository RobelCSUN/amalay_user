import 'package:flutter/material.dart';

import 'package:amalay_user/theme/app_colors.dart';

class AppTheme {
  static ThemeData get light {
    const textColor = Colors.white;

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.accentWarm,
        onPrimary: Colors.black,
        secondary: AppColors.accentRose,
        onSecondary: Colors.white,
        error: Color(0xFFEF5350),
        onError: Colors.white,
        surface: Color(0xCC0B2236),
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor,
          height: 1.35,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.6),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black.withValues(alpha: 0.80),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
