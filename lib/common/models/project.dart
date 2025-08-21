import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

@HiveType(typeId: 8)
class Project extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late ProjectStatus status;

  @HiveField(4)
  late DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  @HiveField(6)
  late String color;

  @HiveField(7)
  String? icon;

  @HiveField(8)
  List<String>? todoIds;

  @HiveField(9)
  List<String>? goalIds;

  @HiveField(10)
  List<ProjectPhase>? phases;

  @HiveField(11)
  double progress;

  @HiveField(12)
  List<String>? tags;

  @HiveField(13)
  late DateTime createdAt;

  @HiveField(14)
  late DateTime updatedAt;

  @HiveField(15)
  String? notes;

  @HiveField(16)
  Map<String, dynamic>? metadata;

  Project({
    String? id,
    required this.name,
    this.description,
    ProjectStatus? status,
    DateTime? startDate,
    this.endDate,
    String? color,
    this.icon,
    this.todoIds,
    this.goalIds,
    this.phases,
    this.progress = 0,
    this.tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? ProjectStatus.planning,
        startDate = startDate ?? DateTime.now(),
        color = color ?? '#2196F3',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
    String? icon,
    List<String>? todoIds,
    List<String>? goalIds,
    List<ProjectPhase>? phases,
    double? progress,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      todoIds: todoIds ?? this.todoIds,
      goalIds: goalIds ?? this.goalIds,
      phases: phases ?? this.phases,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  void updateProgress() {
    if (phases != null && phases!.isNotEmpty) {
      double totalProgress = 0;
      for (var phase in phases!) {
        totalProgress += phase.progress * (phase.weight ?? 1);
      }
      double totalWeight = phases!.fold(0, (sum, phase) => sum + (phase.weight ?? 1));
      progress = (totalProgress / totalWeight).clamp(0.0, 1.0);
    }
    
    // Update status based on progress
    if (progress >= 1.0 && status == ProjectStatus.active) {
      status = ProjectStatus.completed;
    } else if (progress > 0 && status == ProjectStatus.planning) {
      status = ProjectStatus.active;
    }
    
    updatedAt = DateTime.now();
    save();
  }

  bool get isOverdue {
    if (endDate == null || status == ProjectStatus.completed) return false;
    return DateTime.now().isAfter(endDate!);
  }

  int get daysRemaining {
    if (endDate == null || status == ProjectStatus.completed) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  int get totalTasks => todoIds?.length ?? 0;

  ProjectHealth get health {
    if (status == ProjectStatus.completed) return ProjectHealth.good;
    if (status == ProjectStatus.onHold) return ProjectHealth.atRisk;
    
    if (isOverdue) return ProjectHealth.critical;
    
    if (endDate != null) {
      final totalDays = endDate!.difference(startDate).inDays;
      final elapsedDays = DateTime.now().difference(startDate).inDays;
      if (totalDays > 0) {
        final expectedProgress = (elapsedDays / totalDays).clamp(0.0, 1.0);
        final progressDiff = progress - expectedProgress;
        
        if (progressDiff < -0.2) return ProjectHealth.critical;
        if (progressDiff < -0.1) return ProjectHealth.atRisk;
      }
    }
    
    return ProjectHealth.good;
  }
}

@HiveType(typeId: 9)
class ProjectPhase extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  late DateTime endDate;

  @HiveField(5)
  late double progress;

  @HiveField(6)
  List<String>? todoIds;

  @HiveField(7)
  double? weight;

  @HiveField(8)
  late PhaseStatus status;

  ProjectPhase({
    String? id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.progress = 0,
    this.todoIds,
    this.weight,
    PhaseStatus? status,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? PhaseStatus.pending;

  void updateProgress(int completedTasks, int totalTasks) {
    if (totalTasks > 0) {
      progress = (completedTasks / totalTasks).clamp(0.0, 1.0);
      
      if (progress >= 1.0) {
        status = PhaseStatus.completed;
      } else if (progress > 0 && status == PhaseStatus.pending) {
        status = PhaseStatus.active;
      }
    }
  }
}

@HiveType(typeId: 10)
enum ProjectStatus {
  @HiveField(0)
  planning,
  @HiveField(1)
  active,
  @HiveField(2)
  onHold,
  @HiveField(3)
  completed,
  @HiveField(4)
  cancelled,
  @HiveField(5)
  archived
}

@HiveType(typeId: 11)
enum PhaseStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  active,
  @HiveField(2)
  completed,
  @HiveField(3)
  skipped
}

@HiveType(typeId: 12)
enum ProjectHealth {
  @HiveField(0)
  good,
  @HiveField(1)
  atRisk,
  @HiveField(2)
  critical
}

// Extensions for display
extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return '规划中';
      case ProjectStatus.active:
        return '进行中';
      case ProjectStatus.onHold:
        return '暂停';
      case ProjectStatus.completed:
        return '已完成';
      case ProjectStatus.cancelled:
        return '已取消';
      case ProjectStatus.archived:
        return '已归档';
    }
  }
}

extension ProjectHealthExtension on ProjectHealth {
  String get displayName {
    switch (this) {
      case ProjectHealth.good:
        return '健康';
      case ProjectHealth.atRisk:
        return '风险';
      case ProjectHealth.critical:
        return '危急';
    }
  }
  
  String get emoji {
    switch (this) {
      case ProjectHealth.good:
        return '🟢';
      case ProjectHealth.atRisk:
        return '🟡';
      case ProjectHealth.critical:
        return '🔴';
    }
  }
}