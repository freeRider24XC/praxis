import 'package:praxis/common/models/project.dart';

class DatabaseService {
  static final List<Project> _projects = [
    Project(
      id: '1',
      name: 'Flutter App Development',
      description: 'Building a cross-platform mobile application',
      status: ProjectStatus.active,
      health: ProjectHealth.good,
      progress: 0.65,
      color: '#2196F3',
      icon: 'work',
      priority: Priority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      startDate: DateTime.now().subtract(const Duration(days: 25)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      totalTasks: 12,
      completedTasks: 8,
    ),
    Project(
      id: '2',
      name: 'Learn Machine Learning',
      description: 'Study ML fundamentals and practice with real projects',
      status: ProjectStatus.active,
      health: ProjectHealth.atRisk,
      progress: 0.35,
      color: '#4CAF50',
      icon: 'study',
      priority: Priority.medium,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      totalTasks: 8,
      completedTasks: 3,
    ),
    Project(
      id: '3',
      name: 'Fitness Journey',
      description: 'Get in shape and maintain healthy lifestyle',
      status: ProjectStatus.onHold,
      health: ProjectHealth.critical,
      progress: 0.20,
      color: '#FF5722',
      icon: 'health',
      priority: Priority.high,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      startDate: DateTime.now().subtract(const Duration(days: 40)),
      endDate: DateTime.now().add(const Duration(days: 60)),
      totalTasks: 15,
      completedTasks: 3,
    ),
  ];
  
  static List<Project> getAllProjects() {
    return List.from(_projects);
  }
  
  static Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static void addProject(Project project) {
    _projects.add(project);
  }
  
  static void updateProject(Project project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
  }
  
  static void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
  }
  
  static List<Project> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }
  
  static List<Project> getActiveProjects() {
    return getProjectsByStatus(ProjectStatus.active);
  }
  
  static List<Project> getCompletedProjects() {
    return getProjectsByStatus(ProjectStatus.completed);
  }
}