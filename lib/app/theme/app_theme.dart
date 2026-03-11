// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:poketracker_go/app/theme/app_colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: AppColors.primaryLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryLight,
      foregroundColor: Colors.black,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: AppColors.primaryDark,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.primaryDark,
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onSurfaceDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurfaceDark,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryDark,
      foregroundColor: Colors.black,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
    ),
  );
}
