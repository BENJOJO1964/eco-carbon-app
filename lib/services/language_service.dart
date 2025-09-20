import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('zh', 'TW'); // 預設為中文繁體
  
  Locale get currentLocale => _currentLocale;
  
  // 支援的語言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'TW'), // 中文繁體
    Locale('zh', 'CN'), // 中文簡體
    Locale('en', ''),   // 英文
  ];
  
  // 語言名稱對應
  static const Map<String, String> languageNames = {
    'zh_TW': '中文繁體',
    'zh_CN': '中文簡體',
    'en': 'English',
  };
  
  LanguageService() {
    _loadLanguage();
  }
  
  // 載入保存的語言設定
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        final parts = languageCode.split('_');
        if (parts.length == 2) {
          _currentLocale = Locale(parts[0], parts[1]);
        } else {
          _currentLocale = Locale(parts[0]);
        }
        notifyListeners();
      }
    } catch (e) {
      // 如果載入失敗，保持默認語言
      print('Failed to load language preference: $e');
    }
  }
  
  // 切換語言
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    
    print('Changing language from ${_currentLocale} to $locale');
    _currentLocale = locale;
    notifyListeners();
    
    // 保存語言設定
    final prefs = await SharedPreferences.getInstance();
    final languageCode = locale.countryCode != null 
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString(_languageKey, languageCode);
    print('Language changed to: $languageCode');
  }
  
  // 獲取當前語言名稱
  String get currentLanguageName {
    final languageCode = _currentLocale.countryCode != null 
        ? '${_currentLocale.languageCode}_${_currentLocale.countryCode}'
        : _currentLocale.languageCode;
    return languageNames[languageCode] ?? '中文繁體';
  }
  
  // 獲取語言選項列表
  List<Map<String, dynamic>> get languageOptions {
    return supportedLocales.map((locale) {
      final languageCode = locale.countryCode != null && locale.countryCode!.isNotEmpty
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      return {
        'locale': locale,
        'name': languageNames[languageCode] ?? languageCode,
        'code': languageCode,
      };
    }).toList();
  }
}
