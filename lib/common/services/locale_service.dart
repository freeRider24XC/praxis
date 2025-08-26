import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends GetxService {
  static const String _keyLocale = 'locale';
  static const Locale _fallbackLocale = Locale('en', 'US');
  
  final Rx<Locale> _locale = _fallbackLocale.obs;
  Locale get locale => _locale.value;
  
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];
  
  static const Map<String, String> localeNames = {
    'en_US': 'English',
    'zh_CN': '中文',
  };
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLocaleFromStorage();
  }
  
  Future<void> _loadLocaleFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeString = prefs.getString(_keyLocale);
      
      if (localeString != null) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          final locale = Locale(parts[0], parts[1]);
          if (supportedLocales.contains(locale)) {
            _locale.value = locale;
            Get.updateLocale(locale);
            return;
          }
        }
      }
      
      // 如果没有保存的语言设置，使用系统语言
      final systemLocale = Get.deviceLocale;
      if (systemLocale != null && supportedLocales.contains(systemLocale)) {
        _locale.value = systemLocale;
        Get.updateLocale(systemLocale);
      } else {
        // 回退到默认语言
        _locale.value = _fallbackLocale;
        Get.updateLocale(_fallbackLocale);
      }
    } catch (e) {
      _locale.value = _fallbackLocale;
      Get.updateLocale(_fallbackLocale);
    }
  }
  
  Future<void> changeLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocale, '${locale.languageCode}_${locale.countryCode}');
      
      _locale.value = locale;
      Get.updateLocale(locale);
    } catch (e) {
      // 处理保存错误
      print('Failed to save locale: $e');
    }
  }
  
  String getLocaleName(Locale locale) {
    final key = '${locale.languageCode}_${locale.countryCode}';
    return localeNames[key] ?? locale.toString();
  }
  
  bool isCurrentLocale(Locale locale) {
    return _locale.value == locale;
  }
}