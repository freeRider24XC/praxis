import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/services/database_service.dart';

/// Page-facing Goal persistence boundary.
class GoalRepository {
  static List<Goal> getAll() => DatabaseService.getAllGoals();
  static List<Goal> getByDomain(String domainId) =>
      DatabaseService.getGoalsByDomain(domainId).toList();
  static Goal? getById(String id) => DatabaseService.getGoalById(id);
  static Future<void> add(Goal goal) => DatabaseService.addGoal(goal);
  static Future<void> update(Goal goal) => DatabaseService.updateGoal(goal);
  static Future<void> delete(Goal goal) => DatabaseService.deleteGoal(goal);
  static Future<void> recalculateProgress(String goalId) =>
      DatabaseService.recalculateGoalProgress(goalId);
  static Future<void> setProjectLinks(String goalId, List<String> projectIds) =>
      DatabaseService.setGoalProjectLinks(goalId, projectIds);
}
