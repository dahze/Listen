import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.kBackground,
      primaryColor: AppColors.kPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kPrimary,
        secondary: AppColors.kAccent,
        surface: AppColors.kSurface,
        error: AppColors.kError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.kBackground,
        foregroundColor: AppColors.kPrimary,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.kTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.kTextPrimary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.kTextSecondary, fontSize: 12),
        labelLarge: TextStyle(
          color: AppColors.kPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kPrimaryDim),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kPrimaryDim),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.kPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.kTextSecondary),
        hintStyle: const TextStyle(color: AppColors.kTextDisabled),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimary,
          foregroundColor: AppColors.kBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
