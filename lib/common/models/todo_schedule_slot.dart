import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo_schedule_slot.g.dart';

@HiveType(typeId: 26)
class TodoScheduleSlot extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String todoId;

  @HiveField(2)
  late DateTime scheduledDate;

  @HiveField(3)
  DateTime? scheduledStart;

  @HiveField(4)
  DateTime? scheduledEnd;

  @HiveField(5)
  late ScheduleSlotStatus status;

  @HiveField(6)
  late ScheduleSlotSource source;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  TodoScheduleSlot({
    String? id,
    required this.todoId,
    required this.scheduledDate,
    this.scheduledStart,
    this.scheduledEnd,
    ScheduleSlotStatus? status,
    ScheduleSlotSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? ScheduleSlotStatus.scheduled,
        source = source ?? ScheduleSlotSource.ai,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TodoScheduleSlot copyWith({
    String? id,
    String? todoId,
    DateTime? scheduledDate,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    ScheduleSlotStatus? status,
    ScheduleSlotSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoScheduleSlot(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      status: status ?? this.status,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

@HiveType(typeId: 27)
enum ScheduleSlotStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  completed,
  @HiveField(2)
  skipped,
}

@HiveType(typeId: 28)
enum ScheduleSlotSource {
  @HiveField(0)
  ai,
  @HiveField(1)
  manual,
}
