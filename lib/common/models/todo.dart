import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  late bool isDone;

  @HiveField(6)
  late TodoPriority priority;

  @HiveField(7)
  List<String>? tags;

  @HiveField(8)
  String? projectId;

  @HiveField(9)
  String? goalId;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  DateTime? reminderTime;

  @HiveField(12)
  List<String>? subTasks;

  @HiveField(13)
  String? parentId;

  @HiveField(14)
  RecurrenceRule? recurrence;

  @HiveField(15)
  late DateTime updatedAt;

  @HiveField(16)
  String? domainId;

  @HiveField(17)
  ImportanceLevel? importanceLevel;

  @HiveField(18)
  DifficultyLevel? difficultyLevel;

  @HiveField(19)
  bool isCoreTask;

  @HiveField(20)
  int? estimatedMinutes;

  @HiveField(21)
  int? praisePointsEarned;

  Todo({
    String? id,
    required this.title,
    this.description,
    DateTime? createdAt,
    this.dueDate,
    bool? isDone,
    TodoPriority? priority,
    this.tags,
    this.projectId,
    this.goalId,
    this.completedAt,
    this.reminderTime,
    this.subTasks,
    this.parentId,
    this.recurrence,
    DateTime? updatedAt,
    this.domainId,
    this.importanceLevel,
    this.difficultyLevel,
    bool? isCoreTask,
    this.estimatedMinutes,
    this.praisePointsEarned,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        isDone = isDone ?? false,
        priority = priority ?? TodoPriority.medium,
        updatedAt = updatedAt ?? DateTime.now(),
        isCoreTask = isCoreTask ?? false;

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isDone,
    TodoPriority? priority,
    List<String>? tags,
    String? projectId,
    String? goalId,
    DateTime? completedAt,
    DateTime? reminderTime,
    List<String>? subTasks,
    String? parentId,
    RecurrenceRule? recurrence,
    DateTime? updatedAt,
    String? domainId,
    ImportanceLevel? importanceLevel,
    DifficultyLevel? difficultyLevel,
    bool? isCoreTask,
    int? estimatedMinutes,
    int? praisePointsEarned,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      goalId: goalId ?? this.goalId,
      completedAt: completedAt ?? this.completedAt,
      reminderTime: reminderTime ?? this.reminderTime,
      subTasks: subTasks ?? this.subTasks,
      parentId: parentId ?? this.parentId,
      recurrence: recurrence ?? this.recurrence,
      updatedAt: updatedAt ?? DateTime.now(),
      domainId: domainId ?? this.domainId,
      importanceLevel: importanceLevel ?? this.importanceLevel,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      isCoreTask: isCoreTask ?? this.isCoreTask,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      praisePointsEarned: praisePointsEarned ?? this.praisePointsEarned,
    );
  }

  void toggleDone() {
    isDone = !isDone;
    if (isDone) {
      completedAt = DateTime.now();
    } else {
      completedAt = null;
    }
    updatedAt = DateTime.now();
    save();
  }

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate!.isAfter(startOfWeek) && dueDate!.isBefore(endOfWeek);
  }
}

@HiveType(typeId: 1)
enum TodoPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent
}

@HiveType(typeId: 2)
class RecurrenceRule extends HiveObject {
  @HiveField(0)
  late RecurrenceType type;

  @HiveField(1)
  late int interval;

  @HiveField(2)
  List<int>? daysOfWeek; // 1-7 (Monday-Sunday)

  @HiveField(3)
  int? dayOfMonth;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  int? occurrences;

  RecurrenceRule({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.occurrences,
  });
}

@HiveType(typeId: 3)
enum RecurrenceType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly
}

// Extension for priority display
extension TodoPriorityExtension on TodoPriority {
  String get displayName {
    switch (this) {
      case TodoPriority.low:
        return '低';
      case TodoPriority.medium:
        return '中';
      case TodoPriority.high:
        return '高';
      case TodoPriority.urgent:
        return '紧急';
    }
  }

  int get value {
    switch (this) {
      case TodoPriority.low:
        return 0;
      case TodoPriority.medium:
        return 1;
      case TodoPriority.high:
        return 2;
      case TodoPriority.urgent:
        return 3;
    }
  }

  double get coefficient {
    switch (this) {
      case TodoPriority.low:
        return 0.9;
      case TodoPriority.medium:
        return 1.0;
      case TodoPriority.high:
        return 1.2;
      case TodoPriority.urgent:
        return 1.4;
    }
  }
}

@HiveType(typeId: 18)
enum ImportanceLevel {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

extension ImportanceLevelExtension on ImportanceLevel {
  String get displayName {
    switch (this) {
      case ImportanceLevel.high:
        return '高';
      case ImportanceLevel.medium:
        return '中';
      case ImportanceLevel.low:
        return '低';
    }
  }

  double get coefficient {
    switch (this) {
      case ImportanceLevel.high:
        return 1.4;
      case ImportanceLevel.medium:
        return 1.0;
      case ImportanceLevel.low:
        return 0.8;
    }
  }
}

@HiveType(typeId: 19)
enum DifficultyLevel {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.low:
        return '低';
      case DifficultyLevel.medium:
        return '中';
      case DifficultyLevel.high:
        return '高';
    }
  }

  double get coefficient {
    switch (this) {
      case DifficultyLevel.low:
        return 0.9;
      case DifficultyLevel.medium:
        return 1.0;
      case DifficultyLevel.high:
        return 1.2;
    }
  }
}
