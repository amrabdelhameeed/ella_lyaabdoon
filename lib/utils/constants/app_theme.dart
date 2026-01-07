import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static String font(String locale) => locale == 'en' ? 'sans' : 'kufi';

  static TextTheme textTheme(String locale, Color color) => TextTheme(
    bodyLarge: TextStyle(fontFamily: font(locale), color: color),
    bodyMedium: TextStyle(fontFamily: font(locale), color: color),
    bodySmall: TextStyle(fontFamily: font(locale), color: color),
    titleLarge: TextStyle(fontFamily: font(locale), color: color),
    titleMedium: TextStyle(fontFamily: font(locale), color: color),
    titleSmall: TextStyle(fontFamily: font(locale), color: color),
    labelLarge: TextStyle(fontFamily: font(locale), color: color),
    labelMedium: TextStyle(fontFamily: font(locale), color: color),
    labelSmall: TextStyle(fontFamily: font(locale), color: color),
    headlineLarge: TextStyle(fontFamily: font(locale), color: color),
    headlineMedium: TextStyle(fontFamily: font(locale), color: color),
    headlineSmall: TextStyle(fontFamily: font(locale), color: color),
  );

  /// LIGHT THEME
  static ThemeData lightTheme(String locale) => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.greenPrimary,
    scaffoldBackgroundColor: AppColors.lightBg,
    cardColor: AppColors.lightSurface,
    shadowColor: Colors.black12,

    iconTheme: const IconThemeData(color: AppColors.greenDark),

    textTheme: textTheme(locale, AppColors.textDark),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 1,
      iconTheme: IconThemeData(color: AppColors.greenDark),
      titleTextStyle: TextStyle(
        color: AppColors.greenDark,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.greenPrimary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        textStyle: WidgetStateProperty.all(TextStyle(fontFamily: font(locale))),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColors.greenPrimary,
      labelColor: AppColors.greenPrimary,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontFamily: font(locale)),
      unselectedLabelStyle: TextStyle(fontFamily: font(locale)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.greenPrimary,
      unselectedItemColor: Colors.grey,
    ),
  );

  /// DARK THEME
  static ThemeData darkTheme(String locale) => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.greenSecondary,
    scaffoldBackgroundColor: AppColors.darkBg,
    cardColor: AppColors.darkSurface,
    shadowColor: Colors.black,

    iconTheme: const IconThemeData(color: AppColors.greenSecondary),

    textTheme: textTheme(locale, AppColors.textLight),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 1,
      iconTheme: IconThemeData(color: AppColors.greenSecondary),
      titleTextStyle: TextStyle(
        color: AppColors.greenSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.greenSecondary),
        foregroundColor: WidgetStateProperty.all(Colors.black),
        textStyle: WidgetStateProperty.all(TextStyle(fontFamily: font(locale))),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      indicatorColor: AppColors.greenSecondary,
      labelColor: AppColors.greenSecondary,
      unselectedLabelColor: Colors.grey,
      labelStyle: TextStyle(fontFamily: font(locale)),
      unselectedLabelStyle: TextStyle(fontFamily: font(locale)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.greenSecondary,
      unselectedItemColor: Colors.grey,
    ),
  );
}
