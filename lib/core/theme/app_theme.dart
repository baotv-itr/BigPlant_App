import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      fontFamily: 'Afacad',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mainColorPurple,
        primary: AppColors.mainColorPurple,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mainColorPurple,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.mainColorPurple),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.mainColorPurple),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.mainColorPurpleDark,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColorPurple,
          foregroundColor: AppColors.white,
          minimumSize: const Size(220, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
