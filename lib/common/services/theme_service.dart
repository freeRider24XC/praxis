import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/style/design_tokens.dart';

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
  
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: DesignTokens.fontFamilyDefault,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyLarge: GoogleFonts.notoSansSc(),
          bodyMedium: GoogleFonts.notoSansSc(),
          bodySmall: GoogleFonts.notoSansSc(),
        ),
    colorScheme: ColorScheme.fromSeed(
          seedColor: DesignTokens.primaryColor,
      brightness: Brightness.light,
    ),
        appBarTheme: const AppBarTheme(
      centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),  
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing4,
            vertical: DesignTokens.spacing4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing4,
              vertical: DesignTokens.spacing3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing3,
              vertical: DesignTokens.spacing2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
          ),
        ),
  );
  
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: DesignTokens.fontFamilyDefault,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: GoogleFonts.notoSansSc(),
          bodyMedium: GoogleFonts.notoSansSc(),
          bodySmall: GoogleFonts.notoSansSc(),
        ),
    colorScheme: ColorScheme.fromSeed(
          seedColor: DesignTokens.primaryColor,
      brightness: Brightness.dark,
    ),
        appBarTheme: const AppBarTheme(
      centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing4,
            vertical: DesignTokens.spacing4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing4,
              vertical: DesignTokens.spacing3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing3,
              vertical: DesignTokens.spacing2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
          ),
        ),
      );
}