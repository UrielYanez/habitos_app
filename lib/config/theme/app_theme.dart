import 'package:flutter/material.dart';

class AppTheme {
  // ── Paleta principal (morado/violeta del Figma) ──────────────────────────
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9D8DF1);
  static const Color primaryDark = Color(0xFF4A3AB5);

  // ── Semánticos ──────────────────────────────────────────────────────────
  static const Color completed = Color(
    0xFF00B894,
  ); // verde — actividades completadas
  static const Color pending = Color(0xFFE17055); // rojo/naranja — pendientes
  static const Color streak = Color(0xFFFF7675); // llama/racha

  // ── Neutros ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F6FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color divider = Color(0xFFDFE6E9);

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: completed,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    // Cards
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shadowColor: primary.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Botones
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Bottom Nav
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // Text
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: textSecondary),
      bodyMedium: TextStyle(fontSize: 13, color: textSecondary),
      labelSmall: TextStyle(
        fontSize: 11,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    ),
  );
}
