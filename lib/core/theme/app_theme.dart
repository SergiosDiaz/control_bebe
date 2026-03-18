import 'package:flutter/material.dart';

class AppTheme {
  /// Ruta del icono de título en AppBar (Home, Alimentación, Peso, Pañales).
  static const String titleIconAsset = 'assets/images/icon_mibebe.png';
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color primaryPink = Color(0xFFFF4081);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryOrange = Color(0xFFFF9800);
  /// Color para pecho izquierdo en historial (rosa)
  static const Color breastLeft = Color(0xFFFF4081);
  /// Color para pecho derecho en historial (coral/naranja)
  static const Color breastRight = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF9E9E9E);

  static const double cardRadius = 24;
  static const double cardElevation = 0.5;
  static const double dialogRadius = 28;
  static const double fieldRadius = 18;
  static const Color fieldBackground = Color(0xFFF8F9FA);
  static const Color fieldBorder = Color(0xFFE8E9EA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: '.SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: primaryBlue, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textDark,
          foregroundColor: Colors.white,
          elevation: cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
        ),
      ),
    );
  }
}
