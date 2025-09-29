import 'package:flutter/material.dart';
import 'colors.dart';
import 'constants.dart';

ThemeData buildTheme() {
  
  final colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.sandyYellow,
    onPrimary: Colors.black,
    secondary: AppColors.sandyYellow,
    onSecondary: Colors.black,
    error: const Color(0xFFB00020),
    onError: Colors.white,
    surface: AppColors.ebonyClay,
    onSurface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.onSurface,
    textTheme: const TextTheme(
      // We’ll style hero text manually on the header
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(height: 1.35),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      labelStyle: TextStyle(color: colorScheme.primary),
      hintStyle: TextStyle(color: colorScheme.primary.withOpacity(0.6)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2.5),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md, vertical: Spacing.sm),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl, vertical: Spacing.sm),
        shape: const StadiumBorder(),
        backgroundColor: colorScheme.surface, // dark pill (login screen)
        foregroundColor: colorScheme.onSurface,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800, fontSize: TypographyScale.button),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: const TextStyle(decoration: TextDecoration.underline),
      ),
    ),
  );
}
