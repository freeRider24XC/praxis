import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'focus_session.g.dart';

@HiveType(typeId: 13)
class FocusSession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  late int duration; // 秒数

  @HiveField(4)
  String? taskTitle;

  @HiveField(5)
  late bool completed; // 是否完成（倒计时结束）

  @HiveField(6)
  late DateTime createdAt;

  FocusSession({
    String? id,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.taskTitle,
    this.completed = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  FocusSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    String? taskTitle,
    bool? completed,
    DateTime? createdAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      taskTitle: taskTitle ?? this.taskTitle,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'taskTitle': taskTitle,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] as int,
      taskTitle: json['taskTitle'] as String?,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

