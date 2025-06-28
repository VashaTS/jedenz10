// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _key = 'darkMode';
  bool _dark = false;
  bool get isDark => _dark;

  ThemeService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _dark = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _dark = !_dark;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool(_key, _dark);
  }
}
