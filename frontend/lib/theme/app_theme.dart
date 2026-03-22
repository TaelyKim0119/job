import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.void_,
      fontFamily: 'Pretendard',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldWarm,
        secondary: AppColors.purpleMid,
        surface: AppColors.surface,
        onPrimary: AppColors.void_,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 40, fontWeight: FontWeight.w800,
          color: AppColors.textPrimary, height: 1.2,
          letterSpacing: -1.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, height: 1.2,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, height: 1.3,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: -0.3,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary, height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary, height: 1.6,
        ),
        labelLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary, letterSpacing: 0.1,
        ),
        bodySmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary, height: 1.4,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldWarm,
          foregroundColor: AppColors.void_,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
