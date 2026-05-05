import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praxis/common/services/logger_service.dart';

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
      if (systemLocale != null && _isSupportedLocale(systemLocale)) {
        final supportedLocale = _findSupportedLocale(systemLocale);
        _locale.value = supportedLocale;
        Get.updateLocale(supportedLocale);
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

  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any((supported) => supported.languageCode == locale.languageCode);
  }

  Locale _findSupportedLocale(Locale locale) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return _fallbackLocale;
  }

  Future<void> changeLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocale, '${locale.languageCode}_${locale.countryCode}');

      _locale.value = locale;
      Get.updateLocale(locale);
    } catch (e) {
      LoggerService.error('保存语言设置失败', 'LocaleService', e);
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
