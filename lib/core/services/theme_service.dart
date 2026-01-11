import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  AppTheme _currentTheme = AppTheme.forestGreen;

  AppTheme get currentTheme => _currentTheme;
  AppThemeColors get colors => _currentTheme.colors;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;

      if (themeIndex >= 0 && themeIndex < AppTheme.allThemes.length) {
        _currentTheme = AppTheme.allThemes[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = AppTheme.allThemes.indexOf(theme);
      await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  Future<void> setThemeByType(AppThemeType type) async {
    final theme = AppTheme.fromType(type);
    await setTheme(theme);
  }
}
