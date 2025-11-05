import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      print('Failed to save theme mode: $e');
  }
  }
  
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
        appBarTheme: const AppBarTheme(
      centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
  );
  
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
        appBarTheme: const AppBarTheme(
      centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
}