import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  final SharedPreferences _prefs;
  late String _selectedLanguage;

  LanguageController(this._prefs) {
    _selectedLanguage = _prefs.getString('language_code') ?? 'id';
  }

  String get selectedLanguage => _selectedLanguage;

  bool get isEnglish => _selectedLanguage == 'en';

  void updateLanguage(String langCode) {
    if (_selectedLanguage != langCode) {
      _selectedLanguage = langCode;
      _prefs.setString('language_code', langCode);
      notifyListeners();
    }
  }
}
