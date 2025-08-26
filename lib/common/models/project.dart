enum ProjectStatus {
  planning,
  active,
  onHold,
  completed,
  cancelled,
  archived,
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }
}

enum ProjectHealth {
  good,
  atRisk,
  critical,
}

extension ProjectHealthExtension on ProjectHealth {
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
  
  String get displayName {
    switch (this) {
      case ProjectHealth.good:
        return 'Good';
      case ProjectHealth.atRisk:
        return 'At Risk';
      case ProjectHealth.critical:
        return 'Critical';
    }
  }
}

enum Priority {
  low,
  medium,
  high,
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }
}

class Project {
  final String id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final ProjectHealth health;
  final double progress; // 0.0 to 1.0
  final String color; // Hex color string
  final String? icon;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalTasks;
  final int completedTasks;
  
  Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.health,
    required this.progress,
    required this.color,
    this.icon,
    required this.priority,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });
  
  int get daysRemaining {
    if (endDate == null) return 0;
    final now = DateTime.now();
    final difference = endDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }
  
  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && status != ProjectStatus.completed;
  }
  
  double get completionPercentage {
    if (totalTasks == 0) return progress;
    return completedTasks / totalTasks;
  }
  
  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    ProjectHealth? health,
    double? progress,
    String? color,
    String? icon,
    Priority? priority,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    int? totalTasks,
    int? completedTasks,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      health: health ?? this.health,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.index,
      'health': health.index,
      'progress': progress,
      'color': color,
      'icon': icon,
      'priority': priority.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
    };
  }
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: ProjectStatus.values[json['status']],
      health: ProjectHealth.values[json['health']],
      progress: json['progress'].toDouble(),
      color: json['color'],
      icon: json['icon'],
      priority: Priority.values[json['priority']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      startDate: json['startDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['startDate'])
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endDate'])
          : null,
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
    );
  }
}