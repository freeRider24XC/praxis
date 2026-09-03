import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/services/database_service.dart';

/// Page-facing Project persistence boundary.
class ProjectRepository {
  static List<Project> getAll() => DatabaseService.getAllProjects();
  static List<Project> getActive() => DatabaseService.getActiveProjects();
  static Project? getById(String id) => DatabaseService.getProjectById(id);
  static Future<void> add(Project project) =>
      DatabaseService.addProject(project);
  static Future<void> update(Project project) =>
      DatabaseService.updateProject(project);
  static Future<void> delete(Project project) =>
      DatabaseService.deleteProject(project);
  static Future<void> recalculateProgress(String projectId) =>
      DatabaseService.recalculateProjectProgress(projectId);
  static Future<void> setTodoLinks(String projectId, List<String> todoIds) =>
      DatabaseService.setProjectTodoLinks(projectId, todoIds);
}
