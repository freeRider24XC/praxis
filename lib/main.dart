import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:praxis/generated/l10n.dart';
import 'package:praxis/pages/home/index.dart';
import 'package:praxis/common/services/locale_service.dart';
import 'package:praxis/common/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await Get.putAsync(() => LocaleService().onInit().then((_) => LocaleService()));
  await Get.putAsync(() => ThemeService().onInit().then((_) => ThemeService()));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: "Praxis",
      locale: localeService.locale,
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode,
      home: const HomePage(),
    ));
  }
}
