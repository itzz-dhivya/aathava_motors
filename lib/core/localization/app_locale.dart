import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language';
  String _locale = 'en';

  String get locale => _locale;
  bool get isTamil => _locale == 'ta';

  LocaleProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == 'en' || saved == 'ta')) {
        _locale = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(String langCode) async {
    if (_locale == langCode) return;
    _locale = langCode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (_) {}
  }

  void toggleLanguage() {
    setLocale(_locale == 'en' ? 'ta' : 'en');
  }

  String translate(String key) {
    return AppTranslations.get(key, locale: _locale);
  }
}

extension TranslationExtension on BuildContext {
  String tr(String key) {
    try {
      // In case provider isn't ready
      return AppTranslations.get(key);
    } catch (_) {
      return key;
    }
  }
}
