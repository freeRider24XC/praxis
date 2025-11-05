import 'package:hive_flutter/hive_flutter.dart';
import 'package:praxis/common/models/index.dart';

class DatabaseService {
  static const String todoBoxName = 'todos';
  static const String goalBoxName = 'goals';
  static const String projectBoxName = 'projects';
  static const String settingsBoxName = 'settings';

  static late Box<Todo> todoBox;
  static late Box<Goal> goalBox;
  static late Box<Project> projectBox;
  static late Box settingsBox;

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
  }

  static Future<void> _openBoxes() async {
    todoBox = await Hive.openBox<Todo>(todoBoxName);
    goalBox = await Hive.openBox<Goal>(goalBoxName);
    projectBox = await Hive.openBox<Project>(projectBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
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

  static Future<void> updateTodo(Todo todo) async {
    await todo.save();
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

  static Future<void> updateGoal(Goal goal) async {
    await goal.save();
  }

  static Future<void> deleteGoal(Goal goal) async {
    await goal.delete();
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
}