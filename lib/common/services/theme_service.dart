import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zx/common/services/logger_service.dart';
import 'package:zx/common/style/zx_theme.dart';

class ThemeService extends GetxService {
  static const String _keyThemeMode = 'theme_mode';
  
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadThemeFromStorage();
  }
  
  Future<void> _loadThemeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_keyThemeMode);
      
      if (themeModeIndex != null) {
        _themeMode.value = ThemeMode.values[themeModeIndex];
  }
    } catch (e) {
      _themeMode.value = ThemeMode.system;
  }
  }
  
  Future<void> changeThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyThemeMode, themeMode.index);
      
      _themeMode.value = themeMode;
      Get.changeThemeMode(themeMode);
    } catch (e) {
      LoggerService.error('保存主题模式失败', 'ThemeService', e);
    }
  }
  
  ThemeData get lightTheme => ZxTheme.lightTheme;
  
  ThemeData get darkTheme => ZxTheme.darkTheme;
}