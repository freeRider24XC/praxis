import 'package:praxis/common/models/index.dart';

abstract class PraxisRepository {
  UserProfile getProfile();
  List<Goal> getGoals();
  List<Project> getProjects();
  List<XpEvent> getRecentXpEvents({int limit = 4});
  DailyReview? getDailyReviewByDate(DateTime date);
  List<Todo> getRecommendedTodosForToday({int limit = 5});
  List<TodoScheduleSlot> getTodaySchedule();
  List<RewardTodo> getPendingRewardTodos();
  int getPraisePointsBalance();
  Future<void> refreshWeeklySchedule();
  Future<void> toggleTodo(Todo todo);
}
