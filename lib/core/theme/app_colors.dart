import 'package:flutter/material.dart';

// Static color constants - these will be overridden by theme
// For theme-aware colors, use Theme.of(context).colorScheme instead
class AppColors {
  // Primary Palette (Forest Green - default)
  static const Color primary = Color(0xFF00E054);
  static const Color primaryDark = Color(0xFF00CC76);
  static const Color primaryLight = Color(0xFF33FF33);

  // Backgrounds
  static const Color background = Color(0xFF0B1410);
  static const Color backgroundDark = Color(0xFF050505);

  // Surfaces
  static const Color surface = Color(0xFF12211A);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceHighlight = Color(0xFF1F352A);

  static const Color secondary = Color(0xFF2DD4BF);

  // Accent Colors
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentYellow = Color(0xFFEAB308);
  static const Color accentRed = Color(0xFFEF4444);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textSubtle = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF00E054);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
