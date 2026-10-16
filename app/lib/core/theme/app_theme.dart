import 'package:flutter/material.dart';

class AppColors {
  // Islamic Calm Forest Green & Gold Palette
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color secondaryGreen = Color(0xFF2D6A4F);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFE9D8A6);

  // Backgrounds
  static const Color lightBg = Color(0xFFF9F9F6);
  static const Color sepiaBg = Color(0xFFF4ECD8);
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Text colors
  static const Color lightText = Color(0xFF1C1C1C);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color mutedText = Color(0xFF757575);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentGold,
        surface: AppColors.lightBg,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.mutedText,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryGreen,
        primary: AppColors.secondaryGreen,
        secondary: AppColors.accentGold,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.mutedText,
        backgroundColor: AppColors.darkSurface,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
