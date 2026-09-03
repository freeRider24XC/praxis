import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/services/calendar_sync_service.dart';
import 'package:praxis/common/i18n/translations.dart';
import 'package:praxis/common/app_bootstrap_stub.dart'
    if (dart.library.io) 'package:praxis/common/app_bootstrap_io.dart';
import 'package:praxis/pages/focus/focus_page.dart';
import 'package:praxis/pages/main/main_page.dart';
import 'package:praxis/pages/notifications/notifications_page.dart';
import 'package:praxis/pages/onboarding/onboarding_page.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/reward/reward_shop_page.dart';
import 'package:praxis/pages/reward/reward_todo_page.dart';
import 'package:praxis/pages/todo/add_todo_page.dart';
import 'package:praxis/pages/goal/add_goal_page.dart';
import 'package:praxis/pages/project/add_project_page.dart';
import 'package:praxis/pages/ai_chat/ai_interaction_page.dart';

void main() {
  _bootstrapAndLaunch();
}

Future<void> _bootstrapAndLaunch() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await loadLocalApiConfig();
    await DatabaseService.init();
    await RewardService.seedPresetTemplatesIfEmpty();
    await RewardService.scanExpiredTodos();

    await Get.putAsync<LocaleService>(() async {
      final service = LocaleService();
      await service.onInit();
      return service;
    });
    await Get.putAsync<ThemeService>(() async {
      final service = ThemeService();
      await service.onInit();
      return service;
    });
    await CalendarSyncService.init();

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    _launchPraxisApp(const MyApp());
  } catch (error, stackTrace) {
    debugPrint('初始化失败: $error');
    debugPrint('堆栈跟踪: $stackTrace');
    _launchPraxisApp(
      ErrorApp(
        onRetry: _bootstrapAndLaunch,
        onResetLocalData: _resetLocalDataAndLaunch,
      ),
    );
  }
}

Future<void> _resetLocalDataAndLaunch() async {
  try {
    await DatabaseService.resetLocalData();
    await _bootstrapAndLaunch();
  } catch (error, stackTrace) {
    debugPrint('重置本地数据失败: $error');
    debugPrint('堆栈跟踪: $stackTrace');
    _launchPraxisApp(
      ErrorApp(
        onRetry: _bootstrapAndLaunch,
        onResetLocalData: _resetLocalDataAndLaunch,
      ),
    );
  }
}

void _launchPraxisApp(Widget app) {
  if (!kIsWeb) {
    debugPrint('Launching native app with runApp');
    runApp(app);
    return;
  }

  final dispatcher = WidgetsBinding.instance.platformDispatcher;
  debugPrint(
    'Launching web app: implicitView=${dispatcher.implicitView}, viewCount=${dispatcher.views.length}',
  );
  final flutterView = dispatcher.implicitView ??
      (dispatcher.views.isNotEmpty ? dispatcher.views.first : null);

  if (flutterView == null) {
    debugPrint('No explicit FlutterView available, falling back to runApp');
    runApp(app);
    return;
  }

  debugPrint('Launching web app with explicit View: ${flutterView.viewId}');
  runWidget(
    View(
      view: flutterView,
      child: app,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      RewardService.scanExpiredTodos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeService = Get.find<LocaleService>();
    final themeService = Get.find<ThemeService>();

    // 仅允许在 debug 构建中通过 dart-define 临时绕过 onboarding。
    const skipOnboardingForDebug = kDebugMode &&
        bool.fromEnvironment('SKIP_ONBOARDING', defaultValue: false);

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
          home: skipOnboardingForDebug
              ? const MainPage()
              // ignore: dead_code  调试开关：skipOnboardingForDebug=true 时不执行
              : FutureBuilder<bool>(
                  future: OnboardingChecker.shouldShowOnboarding(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return snapshot.data == true
                        ? const OnboardingPage()
                        : const MainPage();
                  },
                ),
          getPages: [
            GetPage(name: '/MainPage', page: () => const MainPage()),
            GetPage(
                name: '/OnboardingPage', page: () => const OnboardingPage()),
            GetPage(name: '/todo/add', page: () => const AddTodoPage()),
            GetPage(name: '/goal/add', page: () => const AddGoalPage()),
            GetPage(name: '/project/add', page: () => const AddProjectPage()),
            GetPage(name: '/ai/chat', page: () => const AiInteractionPage()),
            GetPage(
                name: '/project/detail/:id',
                page: () {
                  final id = Get.parameters['id']!;
                  return ProjectDetailPage(projectId: id);
                }),
            GetPage(name: '/focus', page: () => const FocusPage()),
            GetPage(
                name: '/notifications', page: () => const NotificationsPage()),
            GetPage(name: '/reward/shop', page: () => const RewardShopPage()),
            GetPage(name: '/reward/todo', page: () => const RewardTodoPage()),
          ],
        ));
  }
}

class ErrorApp extends StatefulWidget {
  const ErrorApp({
    required this.onRetry,
    required this.onResetLocalData,
    super.key,
  });

  final Future<void> Function() onRetry;
  final Future<void> Function() onResetLocalData;

  @override
  State<ErrorApp> createState() => _ErrorAppState();
}

class _ErrorAppState extends State<ErrorApp> {
  bool _isWorking = false;

  Future<void> _retry() async {
    setState(() => _isWorking = true);
    await widget.onRetry();
  }

  Future<void> _confirmAndReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置本地数据？'),
        content: const Text('这会删除本机保存的目标、项目、待办、专注和设置数据，且无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认重置'),
          ),
        ],
      ),
    );

    if (shouldReset != true || !mounted) return;
    setState(() => _isWorking = true);
    await widget.onResetLocalData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praxis - 错误',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  '应用初始化失败',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请先重试。若持续失败，可重置本地数据后重新开始。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isWorking ? null : _retry,
                  child: const Text('重试'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isWorking ? null : _confirmAndReset,
                  child: const Text('重置本地数据'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
