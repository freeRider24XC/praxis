import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:zx/common/services/index.dart';
import 'package:zx/common/services/locale_service.dart';
import 'package:zx/common/i18n/translations.dart';
import 'package:zx/common/ai/services/zx_ai_service.dart';
import 'package:zx/pages/main/main_page.dart';
import 'package:zx/pages/todo/add_todo_page.dart';
import 'package:zx/pages/goal/add_goal_page.dart';
import 'package:zx/pages/project/add_project_page.dart';
import 'package:zx/pages/ai_chat/ai_chat_page.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 加载本地API配置
    await _loadLocalApiConfig();

  // Initialize database
  await DatabaseService.init();
    
    // Initialize services
    await Get.putAsync(() => LocaleService().onInit().then((_) => LocaleService()));
    await Get.putAsync(() => ThemeService().onInit().then((_) => ThemeService()));
    Get.put(ZxAIService());
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
  } catch (e, stackTrace) {
    // Log error and show error screen
    debugPrint('初始化失败: $e');
    debugPrint('堆栈跟踪: $stackTrace');
    runApp(const ErrorApp());
  }
}

/// 加载本地API配置文件
Future<void> _loadLocalApiConfig() async {
  try {
    final configFile = File('local_config/minimax_api_key.txt');
    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      final lines = content.split('\n');
      String? apiKey;

      for (final line in lines) {
        if (line.startsWith('API_KEY=')) {
          apiKey = line.split('=')[1].trim();
          break;
        }
      }

      if (apiKey != null && apiKey.isNotEmpty) {
        // 检查是否已配置，未配置时才设置
        final currentKey = await AiConfigService.getApiKey();
        if (currentKey == null || currentKey.isEmpty) {
          await AiConfigService.setMiniMax(apiKey: apiKey);
          debugPrint('已从 local_config/minimax_api_key.txt 加载 MiniMax API 配置');
        }
      }
    }
  } catch (e) {
    debugPrint('加载本地API配置失败: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: "ZhiXing (知行)",
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: localeService.locale,
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleService.supportedLocales,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode,
      home: const MainPage(),
      getPages: [
        GetPage(name: '/todo/add', page: () => const AddTodoPage()),
        GetPage(name: '/goal/add', page: () => const AddGoalPage()),
        GetPage(name: '/project/add', page: () => const AddProjectPage()),
        GetPage(name: '/ai/chat', page: () => const AiChatPage()),
      ],
    ));
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ZhiXing (知行) - 错误",
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  '应用初始化失败',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请检查控制台日志以获取详细信息',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // 尝试重新启动应用
                    main();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
