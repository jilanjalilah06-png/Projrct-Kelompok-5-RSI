import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  final SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeController(this._prefs) {
    final themeStr = _prefs.getString('theme_mode') ?? 'light';
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void updateTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      
      String themeStr = 'light';
      if (mode == ThemeMode.dark) themeStr = 'dark';
      if (mode == ThemeMode.system) themeStr = 'system';
      _prefs.setString('theme_mode', themeStr);
      
      notifyListeners();
    }
  }
}
