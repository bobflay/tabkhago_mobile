import 'package:flutter/material.dart';

class AppTheme {
  // Lebanese flag colors
  static const Color lebanonRed = Color(0xFFED1C24);
  static const Color lebanonWhite = Color(0xFFFFFFFF);
  static const Color lebanonGreen = Color(0xFF00A651);
  
  // Additional colors for the app
  static const Color backgroundGray = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textLight = Color(0xFF666666);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: lebanonRed,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lebanonRed,
      primary: lebanonRed,
      secondary: lebanonGreen,
      surface: lebanonWhite,
    ),
    scaffoldBackgroundColor: backgroundGray,
    appBarTheme: const AppBarTheme(
      backgroundColor: lebanonRed,
      foregroundColor: lebanonWhite,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lebanonRed,
        foregroundColor: lebanonWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lebanonGreen,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lebanonWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lebanonRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      hintStyle: TextStyle(color: textLight.withValues(alpha: 0.7)),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: lebanonWhite,
    ),
  );
}