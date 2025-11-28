import 'package:hive_flutter/hive_flutter.dart';
import 'package:praxis/common/models/index.dart';

class DatabaseService {
  static const String todoBoxName = 'todos';
  static const String goalBoxName = 'goals';
  static const String projectBoxName = 'projects';
  static const String settingsBoxName = 'settings';
  static const String focusSessionBoxName = 'focus_sessions';

  static late Box<Todo> todoBox;
  static late Box<Goal> goalBox;
  static late Box<Project> projectBox;
  static late Box settingsBox;
  static late Box<FocusSession> focusSessionBox;

  static bool _isInitialized = false;

  // Initialize Hive and register adapters
  static Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();

    // Register adapters
    _registerAdapters();

    // Open boxes
    await _openBoxes();
    
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
  }

  static Future<void> _openBoxes() async {
    todoBox = await Hive.openBox<Todo>(todoBoxName);
    goalBox = await Hive.openBox<Goal>(goalBoxName);
    projectBox = await Hive.openBox<Project>(projectBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
    focusSessionBox = await Hive.openBox<FocusSession>(focusSessionBoxName);
  }

  // Todo operations
  static Future<void> addTodo(Todo todo) async {
    await todoBox.add(todo);
  }

  // 批量添加待办事项
  static Future<void> addTodos(List<Todo> todos) async {
    for (final todo in todos) {
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
    return todoBox.values
        .where((todo) => todo.projectId == projectId)
        .toList();
  }

  static List<Todo> getTodosByGoal(String goalId) {
    return todoBox.values
        .where((todo) => todo.goalId == goalId)
        .toList();
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
    return goalBox.values
        .where((goal) => goal.type == type)
        .toList();
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
    final hasValueTarget = (goal.targetValue ?? 0) > 0 && goal.currentValue != null;

    if (hasValueTarget) {
      newProgress = (goal.currentValue! / goal.targetValue!).clamp(0.0, 1.0);
    } else if (goal.projectIds != null && goal.projectIds!.isNotEmpty) {
      final linkedProjects = goal.projectIds!
          .map(getProjectById)
          .whereType<Project>()
          .toList();
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

    final todos = project.todoIds
            ?.map(getTodoById)
            .whereType<Todo>()
            .toList() ??
        [];

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
            oldProject.todoIds =
                oldTodoIds.isEmpty ? null : oldTodoIds;
            await oldProject.save();
            affectedProjectIds.add(oldProject.id);
          }
        }
      }

      todo.projectId = projectId;
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
  }

  // Close database
  static Future<void> close() async {
    await todoBox.close();
    await goalBox.close();
    await projectBox.close();
    await settingsBox.close();
    await Hive.close();
  }

  // Backup and restore
  static Map<String, dynamic> backupData() {
    return {
      'todos': todoBox.values.map((todo) => _todoToMap(todo)).toList(),
      'goals': goalBox.values.map((goal) => _goalToMap(goal)).toList(),
      'projects': projectBox.values.map((project) => _projectToMap(project)).toList(),
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
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      reminderTime: map['reminderTime'] != null ? DateTime.parse(map['reminderTime']) : null,
      subTasks: map['subTasks'] != null ? List<String>.from(map['subTasks']) : null,
      parentId: map['parentId'],
      updatedAt: DateTime.parse(map['updatedAt']),
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
      milestones: map['milestones'] != null ? List<String>.from(map['milestones']) : null,
      parentGoalId: map['parentGoalId'],
      subGoalIds: map['subGoalIds'] != null ? List<String>.from(map['subGoalIds']) : null,
      linkedTodoIds: map['linkedTodoIds'] != null ? List<String>.from(map['linkedTodoIds']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'],
      targetValue: map['targetValue'],
      currentValue: map['currentValue'],
      unit: map['unit'],
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
      todoIds: map['todoIds'] != null ? List<String>.from(map['todoIds']) : null,
      goalIds: map['goalIds'] != null ? List<String>.from(map['goalIds']) : null,
      progress: map['progress'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      notes: map['notes'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
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
}