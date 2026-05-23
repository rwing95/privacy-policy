import 'package:flutter/material.dart';

class SteamColors {
  static const Color background = Color(0xFF1B2838);
  static const Color surface = Color(0xFF2A475E);
  static const Color surfaceVariant = Color(0xFF1E3447);
  static const Color card = Color(0xFF16202D);
  static const Color accent = Color(0xFF66C0F4);
  static const Color accentDark = Color(0xFF4B91C4);
  static const Color textPrimary = Color(0xFFC7D5E0);
  static const Color textSecondary = Color(0xFF8FA3B1);
  static const Color textMuted = Color(0xFF556C7A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color divider = Color(0xFF2D3F50);
  static const Color shimmerBase = Color(0xFF243447);
  static const Color shimmerHighlight = Color(0xFF2E4459);
}

class SteamTheme {
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SteamColors.background,
        primaryColor: SteamColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: SteamColors.accent,
          secondary: SteamColors.accentDark,
          surface: SteamColors.surface,
          onPrimary: SteamColors.background,
          onSecondary: SteamColors.textPrimary,
          onSurface: SteamColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: SteamColors.card,
          foregroundColor: SteamColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: SteamColors.card,
          selectedItemColor: SteamColors.accent,
          unselectedItemColor: SteamColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: SteamColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        dividerColor: SteamColors.divider,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: SteamColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: SteamColors.textPrimary, fontSize: 14),
          bodyMedium: TextStyle(color: SteamColors.textSecondary, fontSize: 13),
          bodySmall: TextStyle(color: SteamColors.textMuted, fontSize: 12),
          labelSmall: TextStyle(
            color: SteamColors.accent,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SteamColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: SteamColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: SteamColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: SteamColors.accent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: SteamColors.textSecondary),
          hintStyle: const TextStyle(color: SteamColors.textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SteamColors.accent,
            foregroundColor: SteamColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      );
}
