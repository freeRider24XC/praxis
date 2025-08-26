import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database_service.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'theme_color';

  // Predefined theme colors
  static final List<MaterialColor> themeColors = [
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.deepPurple,
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
  ];

  static final List<String> themeNames = [
    '天空蓝',
    '靛青',
    '紫色',
    '深紫',
    '粉红',
    '红色',
    '深橙',
    '橙色',
    '琥珀',
    '绿色',
    '青绿',
    '青色',
  ];

  // Get current theme mode
  static ThemeMode get themeMode {
    final modeIndex = DatabaseService.getSetting(_themeKey, defaultValue: 0);
    return ThemeMode.values[modeIndex];
  }

  // Get current theme color index
  static int get colorIndex {
    return DatabaseService.getSetting(_colorKey, defaultValue: 0);
  }

  // Get current theme color
  static MaterialColor get themeColor {
    return themeColors[colorIndex];
  }

  // Save theme mode
  static Future<void> saveThemeMode(ThemeMode mode) async {
    await DatabaseService.setSetting(_themeKey, mode.index);
  }

  // Save theme color
  static Future<void> saveThemeColor(int index) async {
    await DatabaseService.setSetting(_colorKey, index);
    Get.changeTheme(getThemeData(isDark: Get.isDarkMode));
  }

  // Toggle theme mode
  static Future<void> toggleTheme() async {
    final currentMode = themeMode;
    final newMode = currentMode == ThemeMode.light
        ? ThemeMode.dark
        : currentMode == ThemeMode.dark
            ? ThemeMode.system
            : ThemeMode.light;
    
    await saveThemeMode(newMode);
    Get.changeThemeMode(newMode);
  }

  // Get theme data
  static ThemeData getThemeData({bool isDark = false}) {
    final color = themeColor;
    
    if (isDark) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: color,
        
        // AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        
        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        
        // Floating action button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // Chip theme
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: color,
        
        // AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        
        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        
        // Floating action button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // Chip theme
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Get status bar brightness
  static Brightness getStatusBarBrightness() {
    return Get.isDarkMode ? Brightness.light : Brightness.dark;
  }

  // Check if dark mode
  static bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode == ThemeMode.dark;
  }
}