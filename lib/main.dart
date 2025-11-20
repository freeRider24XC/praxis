import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/services/locale_service.dart';
import 'package:praxis/common/i18n/translations.dart';
import 'package:praxis/pages/focus/focus_page.dart';
import 'package:praxis/pages/main/main_page.dart';
import 'package:praxis/pages/notifications/notifications_page.dart';
import 'package:praxis/pages/onboarding/onboarding_page.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/todo/add_todo_page.dart';
import 'package:praxis/pages/goal/add_goal_page.dart';
import 'package:praxis/pages/project/add_project_page.dart';
import 'package:praxis/pages/ai_chat/ai_chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
  // Initialize database
  await DatabaseService.init();
    
    // Initialize services
    await Get.putAsync(() => LocaleService().onInit().then((_) => LocaleService()));
    await Get.putAsync(() => ThemeService().onInit().then((_) => ThemeService()));
  
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      title: "Praxis",
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
          home: FutureBuilder<bool>(
            future: OnboardingChecker.shouldShowOnboarding(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data == true ? const OnboardingPage() : const MainPage();
            },
          ),
      getPages: [
        GetPage(name: '/todo/add', page: () => const AddTodoPage()),
        GetPage(name: '/goal/add', page: () => const AddGoalPage()),
        GetPage(name: '/project/add', page: () => const AddProjectPage()),
        GetPage(name: '/ai/chat', page: () => const AiChatPage()),
            GetPage(
                name: '/project/detail/:id',
                page: () {
                  final id = Get.parameters['id']!;
                  return ProjectDetailPage(projectId: id);
                }),
            GetPage(name: '/focus', page: () => const FocusPage()),
            GetPage(name: '/notifications', page: () => const NotificationsPage()),
      ],
    ));
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Praxis - 错误",
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
