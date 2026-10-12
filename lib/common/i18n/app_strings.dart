import 'package:get/get.dart';

/// 应用字符串键 - 类型安全的多语言键定义
/// 使用此类可以获得IDE自动补全支持
///
/// 使用示例：
/// ```dart
/// Text(AppStrings.projectManagement.tr)
/// Text(AppStrings.daysRemaining.trNamed({'days': '5'}))
/// ```
class AppStrings {
  AppStrings._();

  // ==================== 通用 ====================
  static const String title = 'title';
  static const String appName = 'appName';
  static const String save = 'save';
  static const String cancel = 'cancel';
  static const String delete = 'delete';
  static const String edit = 'edit';
  static const String add = 'add';
  static const String confirm = 'confirm';
  static const String close = 'close';
  static const String description = 'description';

  // ==================== 底部导航 ====================
  static const String bottomNavHome = 'bottomNavHome';
  static const String bottomNavProjects = 'bottomNavProjects';
  static const String bottomNavGoals = 'bottomNavGoals';
  static const String bottomNavTodos = 'bottomNavTodos';
  static const String bottomNavStats = 'bottomNavStats';

  // ==================== 页面标题 ====================
  static const String projectManagement = 'projectManagement';
  static const String goalManagement = 'goalManagement';
  static const String todoList = 'todoList';
  static const String statistics = 'statistics';
  static const String settings = 'settings';

  // ==================== 项目相关 ====================
  static const String allProjects = 'allProjects';
  static const String filterByStatus = 'filterByStatus';
  static const String createProject = 'createProject';
  static const String noProjectsFound = 'noProjectsFound';
  static const String noProjectsWithStatus = 'noProjectsWithStatus';
  static const String notCreatedAnyProjects = 'notCreatedAnyProjects';

  // 项目状态
  static const String projectStatusPlanning = 'projectStatusPlanning';
  static const String projectStatusActive = 'projectStatusActive';
  static const String projectStatusOnHold = 'projectStatusOnHold';
  static const String projectStatusCompleted = 'projectStatusCompleted';
  static const String projectStatusCancelled = 'projectStatusCancelled';
  static const String projectStatusArchived = 'projectStatusArchived';

  // 项目健康度
  static const String projectHealthGood = 'projectHealthGood';
  static const String projectHealthAtRisk = 'projectHealthAtRisk';
  static const String projectHealthCritical = 'projectHealthCritical';

  // 项目字段
  static const String projectName = 'projectName';
  static const String projectDescription = 'projectDescription';
  static const String projectIcon = 'projectIcon';
  static const String projectColor = 'projectColor';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';

  // ==================== 视图 ====================
  static const String gridView = 'gridView';
  static const String listView = 'listView';

  // ==================== 添加 ====================
  static const String addNewTodo = 'addNewTodo';
  static const String addNewGoal = 'addNewGoal';
  static const String addNewProject = 'addNewProject';

  // ==================== 语言和主题 ====================
  static const String language = 'language';
  static const String english = 'english';
  static const String chinese = 'chinese';
  static const String theme = 'theme';
  static const String lightTheme = 'lightTheme';
  static const String darkTheme = 'darkTheme';
  static const String systemTheme = 'systemTheme';

  // ==================== 优先级 ====================
  static const String priority = 'priority';
  static const String highPriority = 'highPriority';
  static const String mediumPriority = 'mediumPriority';
  static const String lowPriority = 'lowPriority';

  // ==================== 图标 ====================
  static const String iconWork = 'iconWork';
  static const String iconPersonal = 'iconPersonal';
  static const String iconStudy = 'iconStudy';
  static const String iconHealth = 'iconHealth';
  static const String iconFinance = 'iconFinance';
  static const String iconOther = 'iconOther';

  // ==================== 应用信息 ====================
  static const String appInfo = 'appInfo';
  static const String version = 'version';

  // ==================== 带参数的翻译 ====================
  static const String daysRemaining = 'daysRemaining';
  static const String progressPercentage = 'progressPercentage';
  static const String taskCount = 'taskCount';

  // ==================== 项目详情对话框 ====================
  static const String projectStatus = 'projectStatus';
  static const String projectProgress = 'projectProgress';
  static const String projectEndDate = 'projectEndDate';
  static const String projectDaysRemaining = 'projectDaysRemaining';
  static const String adjustFilter = 'adjustFilter';
  static const String startCreatingProject = 'startCreatingProject';

  // ==================== 奖励商店 ====================
  static const String rewardShopTitle = 'rewardShopTitle';
  static const String rewardShopBalance = 'rewardShopBalance';
  static const String rewardShopEmptyHint = 'rewardShopEmptyHint';
  static const String rewardShopPresetBadge = 'rewardShopPresetBadge';
  static const String rewardTierSmall = 'rewardTierSmall';
  static const String rewardTierMedium = 'rewardTierMedium';
  static const String rewardTierLarge = 'rewardTierLarge';
  static const String rewardTierFilterAll = 'rewardTierFilterAll';
  static const String rewardExchangeAction = 'rewardExchangeAction';
  static const String rewardExchangeConfirmTitle = 'rewardExchangeConfirmTitle';
  static const String rewardExchangeConfirmBody = 'rewardExchangeConfirmBody';
  static const String rewardExchangeSuccess = 'rewardExchangeSuccess';
  static const String rewardInsufficientPoints = 'rewardInsufficientPoints';
  static const String rewardEntryCta = 'rewardEntryCta';
  static const String rewardBalanceLabel = 'rewardBalanceLabel';

  // ==================== 奖励待办 ====================
  static const String rewardTodoTitle = 'rewardTodoTitle';
  static const String rewardEntryTodoCta = 'rewardEntryTodoCta';
  static const String rewardShopMyTodosCta = 'rewardShopMyTodosCta';
  static const String rewardTodoEmptyHint = 'rewardTodoEmptyHint';
  static const String rewardTodoCompleteAction = 'rewardTodoCompleteAction';
  static const String rewardTodoCompleteSuccess = 'rewardTodoCompleteSuccess';
  static const String rewardTodoDueLabel = 'rewardTodoDueLabel';
  static const String rewardTodoGroupPending = 'rewardTodoGroupPending';
  static const String rewardTodoGroupCompleted = 'rewardTodoGroupCompleted';
  static const String rewardTodoGroupExpired = 'rewardTodoGroupExpired';
  static const String rewardTodoCount = 'rewardTodoCount';
}

/// 扩展方法：为字符串添加带命名参数的翻译方法
extension StringTranslation on String {
  /// 翻译字符串（带命名参数，使用@key格式）
  ///
  /// 示例：
  /// ```dart
  /// AppStrings.daysRemaining.trNamed({'days': '5'})
  /// // 结果: "5天" 或 "5 days"
  /// ```
  String trNamed(Map<String, String> params) {
    String result = tr;
    params.forEach((key, value) {
      result = result.replaceAll('@$key', value);
    });
    return result;
  }
}
