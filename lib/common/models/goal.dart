import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

@HiveType(typeId: 4)
class Goal extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late GoalType type;

  @HiveField(4)
  late DateTime startDate;

  @HiveField(5)
  late DateTime targetDate;

  @HiveField(6)
  late GoalStatus status;

  @HiveField(7)
  double progress;

  @HiveField(8)
  String? category;

  @HiveField(9)
  List<String>? milestones;

  @HiveField(10)
  List<KeyResult>? keyResults;

  @HiveField(11)
  String? parentGoalId;

  @HiveField(12)
  List<String>? subGoalIds;

  @HiveField(13)
  List<String>? linkedTodoIds;

  @HiveField(14)
  late DateTime createdAt;

  @HiveField(15)
  late DateTime updatedAt;

  @HiveField(16)
  String? notes;

  @HiveField(17)
  int? targetValue;

  @HiveField(18)
  int? currentValue;

  @HiveField(19)
  String? unit;

  Goal({
    String? id,
    required this.title,
    this.description,
    required this.type,
    DateTime? startDate,
    required this.targetDate,
    GoalStatus? status,
    this.progress = 0,
    this.category,
    this.milestones,
    this.keyResults,
    this.parentGoalId,
    this.subGoalIds,
    this.linkedTodoIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
    this.targetValue,
    this.currentValue,
    this.unit,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        status = status ?? GoalStatus.notStarted,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    DateTime? startDate,
    DateTime? targetDate,
    GoalStatus? status,
    double? progress,
    String? category,
    List<String>? milestones,
    List<KeyResult>? keyResults,
    String? parentGoalId,
    List<String>? subGoalIds,
    List<String>? linkedTodoIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    int? targetValue,
    int? currentValue,
    String? unit,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      category: category ?? this.category,
      milestones: milestones ?? this.milestones,
      keyResults: keyResults ?? this.keyResults,
      parentGoalId: parentGoalId ?? this.parentGoalId,
      subGoalIds: subGoalIds ?? this.subGoalIds,
      linkedTodoIds: linkedTodoIds ?? this.linkedTodoIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
    );
  }

  void updateProgress() {
    if (targetValue != null && currentValue != null && targetValue! > 0) {
      progress = (currentValue! / targetValue!).clamp(0.0, 1.0);
    } else if (keyResults != null && keyResults!.isNotEmpty) {
      double totalProgress = 0;
      for (var kr in keyResults!) {
        totalProgress += kr.progress;
      }
      progress = (totalProgress / keyResults!.length).clamp(0.0, 1.0);
    }
    
    // Update status based on progress
    if (progress >= 1.0) {
      status = GoalStatus.completed;
    } else if (progress > 0 && status == GoalStatus.notStarted) {
      status = GoalStatus.inProgress;
    }
    
    updatedAt = DateTime.now();
    save();
  }

  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && status != GoalStatus.completed;
  }

  int get daysRemaining {
    if (status == GoalStatus.completed) return 0;
    return targetDate.difference(DateTime.now()).inDays;
  }

  double get completionRate {
    if (status == GoalStatus.completed) return 100;
    final totalDays = targetDate.difference(startDate).inDays;
    final elapsedDays = DateTime.now().difference(startDate).inDays;
    if (totalDays <= 0) return 0;
    final expectedProgress = (elapsedDays / totalDays).clamp(0.0, 1.0);
    return (progress / expectedProgress * 100).clamp(0.0, 100.0);
  }
}

@HiveType(typeId: 5)
class KeyResult extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double progress;

  @HiveField(3)
  int? targetValue;

  @HiveField(4)
  int? currentValue;

  @HiveField(5)
  String? unit;

  @HiveField(6)
  late bool isCompleted;

  KeyResult({
    String? id,
    required this.title,
    this.progress = 0,
    this.targetValue,
    this.currentValue,
    this.unit,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  void updateProgress() {
    if (targetValue != null && currentValue != null && targetValue! > 0) {
      progress = (currentValue! / targetValue!).clamp(0.0, 1.0);
      isCompleted = progress >= 1.0;
    }
  }
}

@HiveType(typeId: 6)
enum GoalType {
  @HiveField(0)
  yearly,
  @HiveField(1)
  quarterly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  weekly,
  @HiveField(4)
  custom
}

@HiveType(typeId: 7)
enum GoalStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  paused,
  @HiveField(3)
  completed,
  @HiveField(4)
  cancelled
}

// Extensions for display
extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.yearly:
        return '年度目标';
      case GoalType.quarterly:
        return '季度目标';
      case GoalType.monthly:
        return '月度目标';
      case GoalType.weekly:
        return '周目标';
      case GoalType.custom:
        return '自定义';
    }
  }
}

extension GoalStatusExtension on GoalStatus {
  String get displayName {
    switch (this) {
      case GoalStatus.notStarted:
        return '未开始';
      case GoalStatus.inProgress:
        return '进行中';
      case GoalStatus.paused:
        return '已暂停';
      case GoalStatus.completed:
        return '已完成';
      case GoalStatus.cancelled:
        return '已取消';
    }
  }
}