import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  double _textScaleFactor = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;

  Locale get locale => _locale;
  double get textScaleFactor => _textScaleFactor;
  bool get highContrast => _highContrast;
  bool get reduceMotion => _reduceMotion;

  AppStateProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('languageCode');
    if (lang != null) {
      _locale = Locale(lang);
    }
    
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    _highContrast = prefs.getBool('highContrast') ?? false;
    _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ur'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  Future<void> setTextScaleFactor(double factor) async {
    _textScaleFactor = factor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScaleFactor', factor);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
  }
}
