import 'package:flutter/material.dart';
import '../../utils/constants/app_colors.dart';

class AppTheme {
  static String font(String locale) => locale == 'en' ? 'sans' : 'kufi';
  static const ColorScheme _lightGreenScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.greenPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.greenSecondary,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: Color(0xFFE6F4F1),
    onBackground: AppColors.textDark,
    surface: Colors.white,
    onSurface: AppColors.textDark,
  );

  static const ColorScheme _darkGreenScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.greenSecondary,
    onPrimary: Colors.black,
    secondary: AppColors.greenPrimary,
    onSecondary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.black,
    background: AppColors.darkBg,
    onBackground: AppColors.textLight,
    surface: AppColors.darkSurface,
    onSurface: AppColors.textLight,
  );

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
  /// LIGHT THEME (Soft green/teal variant)
  static ThemeData lightTheme(String locale) => ThemeData(
    dividerColor: Colors.transparent,

    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightGreenScheme,

    scaffoldBackgroundColor: _lightGreenScheme.background,
    cardColor: _lightGreenScheme.surface,
    shadowColor: Colors.black12,

    iconTheme: IconThemeData(color: _lightGreenScheme.primary),

    textTheme: textTheme(locale, _lightGreenScheme.onBackground),

    appBarTheme: AppBarTheme(
      backgroundColor: _lightGreenScheme.surface,
      elevation: 1,
      iconTheme: IconThemeData(color: _lightGreenScheme.primary),
      titleTextStyle: TextStyle(
        fontFamily: font('ar'),
        color: _lightGreenScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(_lightGreenScheme.primary),
        foregroundColor: WidgetStateProperty.all(_lightGreenScheme.onPrimary),
        textStyle: WidgetStateProperty.all(TextStyle(fontFamily: font(locale))),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      indicatorColor: _lightGreenScheme.primary,
      labelColor: _lightGreenScheme.primary,
      unselectedLabelColor: Colors.blueGrey,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightGreenScheme.surface,
      selectedItemColor: _lightGreenScheme.primary,
      unselectedItemColor: Colors.blueGrey,
    ),
  );

  /// DARK THEME
  static ThemeData darkTheme(String locale) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkGreenScheme,
    dividerColor: Colors.transparent,

    scaffoldBackgroundColor: _darkGreenScheme.background,
    cardColor: _darkGreenScheme.surface,
    shadowColor: Colors.black,

    iconTheme: IconThemeData(color: _darkGreenScheme.primary),

    textTheme: textTheme(locale, _darkGreenScheme.onBackground),

    appBarTheme: AppBarTheme(
      backgroundColor: _darkGreenScheme.surface,
      elevation: 1,
      iconTheme: IconThemeData(color: _darkGreenScheme.primary),
      titleTextStyle: TextStyle(
        fontFamily: font('ar'),
        color: _darkGreenScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(_darkGreenScheme.primary),
        foregroundColor: WidgetStateProperty.all(_darkGreenScheme.onPrimary),
      ),
    ),

    tabBarTheme: TabBarThemeData(
      indicatorColor: _darkGreenScheme.primary,
      labelColor: _darkGreenScheme.primary,
      unselectedLabelColor: Colors.blueGrey,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkGreenScheme.surface,
      selectedItemColor: _darkGreenScheme.primary,
      unselectedItemColor: Colors.blueGrey,
    ),
  );
}
