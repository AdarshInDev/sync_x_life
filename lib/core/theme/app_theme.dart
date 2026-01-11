import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType {
  forestGreen,
  oceanBlue,
  sunsetOrange,
  midnightPurple,
  roseGold,
}

class AppThemeColors {
  final Color primary;
  final Color background;
  final Color surface;
  final Color surfaceHighlight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textSubtle;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;

  const AppThemeColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.surfaceHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textSubtle,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
  });
}

class AppTheme {
  final String name;
  final AppThemeType type;
  final AppThemeColors colors;

  const AppTheme({
    required this.name,
    required this.type,
    required this.colors,
  });

  // Forest Green (Default/Current)
  static const forestGreen = AppTheme(
    name: 'Forest Green',
    type: AppThemeType.forestGreen,
    colors: AppThemeColors(
      primary: Color(0xFF00E054),
      background: Color(0xFF0B1410),
      surface: Color(0xFF12211A),
      surfaceHighlight: Color(0xFF1F352A),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB8C5BF),
      textSubtle: Color(0xFF8E9A94),
      accent: Color(0xFF00E054),
      success: Color(0xFF00E054),
      warning: Color(0xFFFFA726),
      error: Color(0xFFEF5350),
    ),
  );

  // Ocean Blue
  static const oceanBlue = AppTheme(
    name: 'Ocean Blue',
    type: AppThemeType.oceanBlue,
    colors: AppThemeColors(
      primary: Color(0xFF00B4D8),
      background: Color(0xFF0A1929),
      surface: Color(0xFF1A2332),
      surfaceHighlight: Color(0xFF2A3F5F),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB8C5D8),
      textSubtle: Color(0xFF8E9AAF),
      accent: Color(0xFF48CAE4),
      success: Color(0xFF06D6A0),
      warning: Color(0xFFFFB703),
      error: Color(0xFFEF476F),
    ),
  );

  // Sunset Orange
  static const sunsetOrange = AppTheme(
    name: 'Sunset Orange',
    type: AppThemeType.sunsetOrange,
    colors: AppThemeColors(
      primary: Color(0xFFFF6B35),
      background: Color(0xFF1A0F0A),
      surface: Color(0xFF2A1F1A),
      surfaceHighlight: Color(0xFF3F2F2A),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFC5B8B8),
      textSubtle: Color(0xFF9A8E8E),
      accent: Color(0xFFFFA07A),
      success: Color(0xFF06D6A0),
      warning: Color(0xFFFFC857),
      error: Color(0xFFE63946),
    ),
  );

  // Midnight Purple
  static const midnightPurple = AppTheme(
    name: 'Midnight Purple',
    type: AppThemeType.midnightPurple,
    colors: AppThemeColors(
      primary: Color(0xFF9D4EDD),
      background: Color(0xFF10002B),
      surface: Color(0xFF240046),
      surfaceHighlight: Color(0xFF3C096C),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFC5B8D8),
      textSubtle: Color(0xFF9A8EC4),
      accent: Color(0xFFC77DFF),
      success: Color(0xFF06D6A0),
      warning: Color(0xFFFFBE0B),
      error: Color(0xFFFF006E),
    ),
  );

  // Rose Gold
  static const roseGold = AppTheme(
    name: 'Rose Gold',
    type: AppThemeType.roseGold,
    colors: AppThemeColors(
      primary: Color(0xFFE8B4B8),
      background: Color(0xFF1A0F12),
      surface: Color(0xFF2A1F22),
      surfaceHighlight: Color(0xFF3F2F32),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFC5B8B9),
      textSubtle: Color(0xFF9A8E8F),
      accent: Color(0xFFFFCCD5),
      success: Color(0xFF06D6A0),
      warning: Color(0xFFFFB703),
      error: Color(0xFFE63946),
    ),
  );

  static const List<AppTheme> allThemes = [
    forestGreen,
    oceanBlue,
    sunsetOrange,
    midnightPurple,
    roseGold,
  ];

  static AppTheme fromType(AppThemeType type) {
    return allThemes.firstWhere((theme) => theme.type == type);
  }

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.accent,
        surface: colors.surface,
        error: colors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: colors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          color: colors.textPrimary,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: colors.textSecondary,
        ),
        bodySmall: GoogleFonts.notoSans(fontSize: 12, color: colors.textSubtle),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: colors.textPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.black,
      ),
    );
  }
}
