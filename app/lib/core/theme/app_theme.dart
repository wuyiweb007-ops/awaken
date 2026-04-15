import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(false);
  static ThemeData dark() => _build(true);

  static ThemeData _build(bool dark) {
    final bg = dark ? AppColors.bgDark : AppColors.bgLight;
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final inkDark = dark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = dark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final accent = dark ? AppColors.accentDark : AppColors.accentLight;
    final divider = dark ? AppColors.dividerDark : AppColors.dividerLight;

    return ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: accent,
        onPrimary: dark ? AppColors.bgDark : Colors.white,
        secondary: dark ? AppColors.goldDark : AppColors.goldLight,
        onSecondary: dark ? AppColors.bgDark : AppColors.inkDarkLight,
        error: dark ? AppColors.priorityADark : AppColors.priorityALight,
        onError: Colors.white,
        surface: surface,
        onSurface: inkDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: inkDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Serif',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: inkDark,
          letterSpacing: 0.5,
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: inkMed,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 0.8,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(
          color: dark ? AppColors.inkLightDark : AppColors.inkLightLight,
          fontSize: 13.5,
        ),
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: 14,
          color: inkDark,
          height: 1.55,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          color: inkMed,
          height: 1.4,
        ),
      ),
      useMaterial3: true,
    );
  }
}
