import 'package:hive_flutter/hive_flutter.dart';
import 'package:praxis/common/models/index.dart';

class DatabaseService {
  static const String todoBoxName = 'todos';
  static const String goalBoxName = 'goals';
  static const String projectBoxName = 'projects';
  static const String settingsBoxName = 'settings';
  static const String focusSessionBoxName = 'focus_sessions';
  static const String lifeDomainBoxName = 'life_domains';
  static const String userProfileBoxName = 'user_profiles';
  static const String xpEventBoxName = 'xp_events';
  static const String dailyReviewBoxName = 'daily_reviews';

  static late Box<Todo> todoBox;
  static late Box<Goal> goalBox;
  static late Box<Project> projectBox;
  static late Box settingsBox;
  static late Box<FocusSession> focusSessionBox;
  static late Box<LifeDomain> lifeDomainBox;
  static late Box<UserProfile> userProfileBox;
  static late Box<XpEvent> xpEventBox;
  static late Box<DailyReview> dailyReviewBox;

  static bool _isInitialized = false;

  // Initialize Hive and register adapters
  static Future<void> init({String? hivePath}) async {
    if (_isInitialized) return;

    if (hivePath != null && hivePath.isNotEmpty) {
      Hive.init(hivePath);
    } else {
      await Hive.initFlutter();
    }

    // Register adapters
    _registerAdapters();

    // Open boxes
    await _openBoxes();
    await _seedDefaults();

    _isInitialized = true;
  }

  // Check if database is initialized
  static bool get isInitialized => _isInitialized;

  static void _registerAdapters() {
    // Todo adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TodoPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecurrenceRuleAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RecurrenceTypeAdapter());
    }

    // Goal adapters
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(KeyResultAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(GoalTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(GoalStatusAdapter());
    }

    // Project adapters
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(ProjectPhaseAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ProjectStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(PhaseStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ProjectHealthAdapter());
    }

    // FocusSession adapters
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(FocusSessionAdapter());
    }

    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(LifeDomainAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(XpEventAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(DailyReviewAdapter());
    }
  }

  static Future<void> _openBoxes() async {
    todoBox = await Hive.openBox<Todo>(todoBoxName);
    goalBox = await Hive.openBox<Goal>(goalBoxName);
    projectBox = await Hive.openBox<Project>(projectBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
    focusSessionBox = await Hive.openBox<FocusSession>(focusSessionBoxName);
    lifeDomainBox = await Hive.openBox<LifeDomain>(lifeDomainBoxName);
    userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);
    xpEventBox = await Hive.openBox<XpEvent>(xpEventBoxName);
    dailyReviewBox = await Hive.openBox<DailyReview>(dailyReviewBoxName);
  }

  static Future<void> _seedDefaults() async {
    if (lifeDomainBox.isEmpty) {
      await lifeDomainBox.addAll([
        LifeDomain(name: '职业发展', icon: '💼', color: '#4F46E5'),
        LifeDomain(name: '健康身体', icon: '🏃', color: '#10B981'),
        LifeDomain(name: '财务管理', icon: '💰', color: '#F59E0B'),
        LifeDomain(name: '人际关系', icon: '👥', color: '#EC4899'),
        LifeDomain(name: '成长学习', icon: '📚', color: '#06B6D4'),
      ]);
    }

    if (userProfileBox.isEmpty) {
      final focusedDomainId = lifeDomainBox.values.isNotEmpty
          ? lifeDomainBox.values.first.id
          : null;
      await userProfileBox.add(
        UserProfile(
          focusedDomainId: focusedDomainId,
        ),
      );
    }
  }

  // Todo operations
  static Future<void> addTodo(Todo todo) async {
    todo.domainId ??= resolveDomainIdForTodo(todo);
    await todoBox.add(todo);
  }

  // 批量添加待办事项
  static Future<void> addTodos(List<Todo> todos) async {
    for (final todo in todos) {
      todo.domainId ??= resolveDomainIdForTodo(todo);
      await todoBox.add(todo);
    }
  }

  static List<Todo> getAllTodos() {
    return todoBox.values.toList();
  }

  static List<Todo> getTodosForToday() {
    final now = DateTime.now();
    return todoBox.values.where((todo) {
      if (todo.isDone) return false;
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == now.year &&
          todo.dueDate!.month == now.month &&
          todo.dueDate!.day == now.day;
    }).toList();
  }

  static List<Todo> getTodosByProject(String projectId) {
    return todoBox.values.where((todo) => todo.projectId == projectId).toList();
  }

  static List<Todo> getTodosByGoal(String goalId) {
    return todoBox.values.where((todo) => todo.goalId == goalId).toList();
  }

  static List<Todo> getOverdueTodos() {
    return todoBox.values.where((todo) => todo.isOverdue).toList();
  }

  static Todo? getTodoById(String id) {
    try {
      return todoBox.values.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateTodo(Todo todo) async {
    todo.domainId ??= resolveDomainIdForTodo(todo);
    await todo.save();
    if (todo.projectId != null) {
      await recalculateProjectProgress(todo.projectId!);
    }
    if (todo.goalId != null) {
      await recalculateGoalProgress(todo.goalId!);
    }
  }

  static Future<void> deleteTodo(Todo todo) async {
    await todo.delete();
  }

  // Goal operations
  static Future<void> addGoal(Goal goal) async {
    goal.domainId ??= getUserProfile().focusedDomainId;
    await goalBox.add(goal);
  }

  static List<Goal> getAllGoals() {
    return goalBox.values.toList();
  }

  static List<Goal> getActiveGoals() {
    return goalBox.values
        .where((goal) => goal.status == GoalStatus.inProgress)
        .toList();
  }

  static List<Goal> getGoalsByType(GoalType type) {
    return goalBox.values.where((goal) => goal.type == type).toList();
  }

  static Goal? getGoalById(String id) {
    try {
      return goalBox.values.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateGoal(Goal goal) async {
    await goal.save();
  }

  static Future<void> deleteGoal(Goal goal) async {
    await goal.delete();
  }

  /// 重新计算目标进度（优先使用数值，其次关联项目平均值）
  static Future<void> recalculateGoalProgress(String goalId) async {
    final goal = getGoalById(goalId);
    if (goal == null) return;

    double newProgress = goal.progress;
    final hasValueTarget =
        (goal.targetValue ?? 0) > 0 && goal.currentValue != null;

    if (hasValueTarget) {
      newProgress = (goal.currentValue! / goal.targetValue!).clamp(0.0, 1.0);
    } else if (goal.projectIds != null && goal.projectIds!.isNotEmpty) {
      final linkedProjects =
          goal.projectIds!.map(getProjectById).whereType<Project>().toList();
      if (linkedProjects.isNotEmpty) {
        final total = linkedProjects.fold<double>(
          0,
          (sum, project) => sum + project.progress,
        );
        newProgress = (total / linkedProjects.length).clamp(0.0, 1.0);
      } else {
        newProgress = 0;
      }
    }

    goal.progress = newProgress;
    goal.updatedAt = DateTime.now();
    await goal.save();
  }

  // Project operations
  static Future<void> addProject(Project project) async {
    if ((project.goalIds?.isNotEmpty ?? false) && project.domainId == null) {
      final primaryGoal = getGoalById(project.goalIds!.first);
      project.domainId = primaryGoal?.domainId ?? project.domainId;
    }
    await projectBox.add(project);
  }

  static List<Project> getAllProjects() {
    return projectBox.values.toList();
  }

  static List<Project> getActiveProjects() {
    return projectBox.values
        .where((project) => project.status == ProjectStatus.active)
        .toList();
  }

  static Project? getProjectById(String id) {
    try {
      return projectBox.values.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateProject(Project project) async {
    await project.save();
  }

  static Future<void> deleteProject(Project project) async {
    await project.delete();
  }

  /// 根据关联任务完成度重新计算项目进度
  static Future<void> recalculateProjectProgress(String projectId) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final todos =
        project.todoIds?.map(getTodoById).whereType<Todo>().toList() ?? [];

    double progress = 0;
    if (todos.isNotEmpty) {
      final completedCount = todos.where((todo) => todo.isDone).length;
      progress = (completedCount / todos.length).clamp(0.0, 1.0);
    }

    project.progress = progress;
    project.updatedAt = DateTime.now();
    await project.save();

    if (project.goalIds != null) {
      for (final goalId in project.goalIds!) {
        await recalculateGoalProgress(goalId);
      }
    }
  }

  /// 链接或解绑目标与项目（批量覆盖）
  static Future<void> setGoalProjectLinks(
    String goalId,
    List<String> projectIds,
  ) async {
    final goal = getGoalById(goalId);
    if (goal == null) return;

    goal.projectIds = projectIds.isEmpty ? null : projectIds;
    await goal.save();

    for (final project in projectBox.values) {
      final goalIds = List<String>.from(project.goalIds ?? []);
      final shouldContain = projectIds.contains(project.id);
      final contains = goalIds.contains(goalId);

      if (shouldContain && !contains) {
        goalIds.add(goalId);
        project.goalIds = goalIds;
        await project.save();
      } else if (!shouldContain && contains) {
        goalIds.remove(goalId);
        project.goalIds = goalIds.isEmpty ? null : goalIds;
        await project.save();
      }
    }

    await recalculateGoalProgress(goalId);
  }

  /// 将任务分配给项目（或取消）
  static Future<void> setProjectTodoLinks(
    String projectId,
    List<String> todoIds,
  ) async {
    final project = getProjectById(projectId);
    if (project == null) return;

    final previousIds = List<String>.from(project.todoIds ?? []);
    final affectedProjectIds = <String>{projectId};

    // 需要移除的任务
    for (final id in previousIds) {
      if (!todoIds.contains(id)) {
        final todo = getTodoById(id);
        if (todo != null && todo.projectId == projectId) {
          todo.projectId = null;
          todo.domainId =
              todo.goalId != null ? getGoalById(todo.goalId!)?.domainId : null;
          await todo.save();
          if (todo.goalId != null) {
            await recalculateGoalProgress(todo.goalId!);
          }
        }
      }
    }

    // 需要新增或更新的任务
    for (final id in todoIds) {
      final todo = getTodoById(id);
      if (todo == null) continue;

      if (todo.projectId != null && todo.projectId != projectId) {
        final oldProject = getProjectById(todo.projectId!);
        if (oldProject != null) {
          final oldTodoIds = List<String>.from(oldProject.todoIds ?? []);
          if (oldTodoIds.remove(id)) {
            oldProject.todoIds = oldTodoIds.isEmpty ? null : oldTodoIds;
            await oldProject.save();
            affectedProjectIds.add(oldProject.id);
          }
        }
      }

      todo.projectId = projectId;
      todo.domainId = project.domainId ?? todo.domainId;
      await todo.save();
      if (todo.goalId != null) {
        await recalculateGoalProgress(todo.goalId!);
      }
    }

    project.todoIds = todoIds.isEmpty ? null : todoIds;
    await project.save();

    for (final id in affectedProjectIds) {
      await recalculateProjectProgress(id);
    }
  }

  // Settings operations
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    if (!_isInitialized) {
      return defaultValue;
    }
    try {
      return settingsBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      return defaultValue;
    }
  }

  static Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static Future<void> removeSetting(String key) async {
    await settingsBox.delete(key);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await todoBox.clear();
    await goalBox.clear();
    await projectBox.clear();
    await settingsBox.clear();
    await focusSessionBox.clear();
    await lifeDomainBox.clear();
    await userProfileBox.clear();
    await xpEventBox.clear();
    await dailyReviewBox.clear();
    await _seedDefaults();
  }

  // Close database
  static Future<void> close() async {
    await todoBox.close();
    await goalBox.close();
    await projectBox.close();
    await settingsBox.close();
    await focusSessionBox.close();
    await lifeDomainBox.close();
    await userProfileBox.close();
    await xpEventBox.close();
    await dailyReviewBox.close();
    await Hive.close();
    _isInitialized = false;
  }

  // Backup and restore
  static Map<String, dynamic> backupData() {
    return {
      'todos': todoBox.values.map((todo) => _todoToMap(todo)).toList(),
      'goals': goalBox.values.map((goal) => _goalToMap(goal)).toList(),
      'projects':
          projectBox.values.map((project) => _projectToMap(project)).toList(),
      'lifeDomains': lifeDomainBox.values
          .map((domain) => {
                'id': domain.id,
                'name': domain.name,
                'icon': domain.icon,
                'color': domain.color,
              })
          .toList(),
      'settings': settingsBox.toMap(),
      'backupDate': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> restoreData(Map<String, dynamic> data) async {
    // Clear existing data
    await clearAllData();

    // Restore todos
    if (data['todos'] != null) {
      for (var todoMap in data['todos']) {
        final todo = _mapToTodo(todoMap);
        await todoBox.add(todo);
      }
    }

    // Restore goals
    if (data['goals'] != null) {
      for (var goalMap in data['goals']) {
        final goal = _mapToGoal(goalMap);
        await goalBox.add(goal);
      }
    }

    // Restore projects
    if (data['projects'] != null) {
      for (var projectMap in data['projects']) {
        final project = _mapToProject(projectMap);
        await projectBox.add(project);
      }
    }

    // Restore settings
    if (data['settings'] != null) {
      final settings = data['settings'] as Map;
      for (var entry in settings.entries) {
        await settingsBox.put(entry.key, entry.value);
      }
    }
  }

  // Helper methods for backup/restore
  static Map<String, dynamic> _todoToMap(Todo todo) {
    return {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'createdAt': todo.createdAt.toIso8601String(),
      'dueDate': todo.dueDate?.toIso8601String(),
      'isDone': todo.isDone,
      'priority': todo.priority.index,
      'tags': todo.tags,
      'projectId': todo.projectId,
      'goalId': todo.goalId,
      'completedAt': todo.completedAt?.toIso8601String(),
      'reminderTime': todo.reminderTime?.toIso8601String(),
      'subTasks': todo.subTasks,
      'parentId': todo.parentId,
      'updatedAt': todo.updatedAt.toIso8601String(),
      'domainId': todo.domainId,
    };
  }

  static Todo _mapToTodo(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isDone: map['isDone'],
      priority: TodoPriority.values[map['priority']],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      projectId: map['projectId'],
      goalId: map['goalId'],
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
      subTasks:
          map['subTasks'] != null ? List<String>.from(map['subTasks']) : null,
      parentId: map['parentId'],
      updatedAt: DateTime.parse(map['updatedAt']),
      domainId: map['domainId'] as String?,
    );
  }

  static Map<String, dynamic> _goalToMap(Goal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'description': goal.description,
      'type': goal.type.index,
      'startDate': goal.startDate.toIso8601String(),
      'targetDate': goal.targetDate.toIso8601String(),
      'status': goal.status.index,
      'progress': goal.progress,
      'category': goal.category,
      'milestones': goal.milestones,
      'parentGoalId': goal.parentGoalId,
      'subGoalIds': goal.subGoalIds,
      'linkedTodoIds': goal.linkedTodoIds,
      'createdAt': goal.createdAt.toIso8601String(),
      'updatedAt': goal.updatedAt.toIso8601String(),
      'notes': goal.notes,
      'targetValue': goal.targetValue,
      'currentValue': goal.currentValue,
      'unit': goal.unit,
      'projectIds': goal.projectIds,
      'domainId': goal.domainId,
    };
  }

  static Goal _mapToGoal(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: GoalType.values[map['type']],
      startDate: DateTime.parse(map['startDate']),
      targetDate: DateTime.parse(map['targetDate']),
      status: GoalStatus.values[map['status']],
      progress: map['progress'],
      category: map['category'],
      milestones: map['milestones'] != null
          ? List<String>.from(map['milestones'])
          : null,
      parentGoalId: map['parentGoalId'],
      subGoalIds: map['subGoalIds'] != null
          ? List<String>.from(map['subGoalIds'])
          : null,
      linkedTodoIds: map['linkedTodoIds'] != null
          ? List<String>.from(map['linkedTodoIds'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'],
      targetValue: map['targetValue'],
      currentValue: map['currentValue'],
      unit: map['unit'],
      projectIds: map['projectIds'] != null
          ? List<String>.from(map['projectIds'])
          : null,
      domainId: map['domainId'] as String?,
    );
  }

  static Map<String, dynamic> _projectToMap(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'status': project.status.index,
      'startDate': project.startDate.toIso8601String(),
      'endDate': project.endDate?.toIso8601String(),
      'color': project.color,
      'icon': project.icon,
      'todoIds': project.todoIds,
      'goalIds': project.goalIds,
      'progress': project.progress,
      'tags': project.tags,
      'createdAt': project.createdAt.toIso8601String(),
      'updatedAt': project.updatedAt.toIso8601String(),
      'notes': project.notes,
      'metadata': project.metadata,
      'domainId': project.domainId,
    };
  }

  static Project _mapToProject(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      status: ProjectStatus.values[map['status']],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      color: map['color'],
      icon: map['icon'],
      todoIds:
          map['todoIds'] != null ? List<String>.from(map['todoIds']) : null,
      goalIds:
          map['goalIds'] != null ? List<String>.from(map['goalIds']) : null,
      progress: map['progress'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      domainId: map['domainId'] as String?,
    );
  }

  // FocusSession operations
  static Future<void> addFocusSession(FocusSession session) async {
    await focusSessionBox.add(session);
  }

  static List<FocusSession> getAllFocusSessions() {
    return focusSessionBox.values.toList();
  }

  static List<FocusSession> getFocusSessionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return focusSessionBox.values.where((session) {
      return session.startTime.isAfter(startOfDay) &&
          session.startTime.isBefore(endOfDay);
    }).toList();
  }

  static int getTotalFocusDuration() {
    // 计算总专注时长（小时）
    final totalSeconds = focusSessionBox.values
        .where((session) => session.completed)
        .fold<int>(0, (sum, session) => sum + session.duration);

    return (totalSeconds / 3600).round(); // 转换为小时并四舍五入
  }

  static Future<void> deleteFocusSession(String id) async {
    final session = focusSessionBox.values.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('FocusSession not found'),
    );
    await session.delete();
  }

  static List<LifeDomain> getAllLifeDomains() {
    return lifeDomainBox.values.toList();
  }

  static LifeDomain? getLifeDomainById(String id) {
    try {
      return lifeDomainBox.values.firstWhere((domain) => domain.id == id);
    } catch (_) {
      return null;
    }
  }

  static UserProfile getUserProfile() {
    if (userProfileBox.values.isEmpty) {
      throw StateError('UserProfile not initialized');
    }
    return userProfileBox.values.first;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    await profile.save();
  }

  static List<XpEvent> getAllXpEvents() {
    final events = xpEventBox.values.toList();
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events;
  }

  static Future<void> addXpEvent(XpEvent event) async {
    await xpEventBox.add(event);
  }

  static List<DailyReview> getAllDailyReviews() {
    final reviews = dailyReviewBox.values.toList();
    reviews.sort((a, b) => b.date.compareTo(a.date));
    return reviews;
  }

  static DailyReview? getDailyReviewByDate(DateTime date) {
    try {
      return dailyReviewBox.values.firstWhere((review) =>
          review.date.year == date.year &&
          review.date.month == date.month &&
          review.date.day == date.day);
    } catch (_) {
      return null;
    }
  }

  static Future<void> upsertDailyReview(DailyReview review) async {
    final existing = getDailyReviewByDate(review.date);
    if (existing == null) {
      await dailyReviewBox.add(review);
      return;
    }
    existing.whatDone = review.whatDone;
    existing.blockers = review.blockers;
    existing.topPriorityTomorrow = review.topPriorityTomorrow;
    existing.xpEarned = review.xpEarned;
    existing.isCompleted = review.isCompleted;
    await existing.save();
  }

  static List<Todo> getTodosByDomain(String domainId) {
    return todoBox.values.where((todo) => todo.domainId == domainId).toList();
  }

  static List<Goal> getGoalsByDomain(String domainId) {
    return goalBox.values.where((goal) => goal.domainId == domainId).toList();
  }

  static List<Project> getProjectsByDomain(String domainId) {
    return projectBox.values
        .where((project) => project.domainId == domainId)
        .toList();
  }

  static List<Todo> getTopTodosForToday({int limit = 3}) {
    final now = DateTime.now();
    final todos = todoBox.values.where((todo) => !todo.isDone).toList();
    todos.sort((a, b) {
      final aScore = _todoSortScore(a, now);
      final bScore = _todoSortScore(b, now);
      if (aScore != bScore) {
        return aScore.compareTo(bScore);
      }
      return b.priority.value.compareTo(a.priority.value);
    });
    return todos.take(limit).toList();
  }

  static int _todoSortScore(Todo todo, DateTime now) {
    if (todo.dueDate == null) return 99;
    final today = DateTime(now.year, now.month, now.day);
    final due =
        DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    return due.difference(today).inDays;
  }

  static String? resolveDomainIdForTodo(Todo todo) {
    if (todo.domainId != null && todo.domainId!.isNotEmpty) {
      return todo.domainId;
    }
    if (todo.projectId != null) {
      final project = getProjectById(todo.projectId!);
      if (project?.domainId != null) {
        return project!.domainId;
      }
    }
    if (todo.goalId != null) {
      final goal = getGoalById(todo.goalId!);
      if (goal?.domainId != null) {
        return goal!.domainId;
      }
    }
    return null;
  }
}
