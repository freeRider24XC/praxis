import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reward_todo.g.dart';

@HiveType(typeId: 24)
enum RewardTodoStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  expired,
  @HiveField(3)
  cancelled,
}

extension RewardTodoStatusExtension on RewardTodoStatus {
  String get displayName {
    switch (this) {
      case RewardTodoStatus.pending:
        return '待兑现';
      case RewardTodoStatus.completed:
        return '已兑现';
      case RewardTodoStatus.expired:
        return '已过期';
      case RewardTodoStatus.cancelled:
        return '已取消';
    }
  }
}

@HiveType(typeId: 25)
class RewardTodo extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String redemptionId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  late RewardTodoStatus status;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  RewardTodo({
    String? id,
    required this.redemptionId,
    required this.title,
    this.notes,
    RewardTodoStatus? status,
    this.dueDate,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? RewardTodoStatus.pending,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  RewardTodo copyWith({
    String? id,
    String? redemptionId,
    String? title,
    String? notes,
    RewardTodoStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewardTodo(
      id: id ?? this.id,
      redemptionId: redemptionId ?? this.redemptionId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isCompleted => status == RewardTodoStatus.completed;
}