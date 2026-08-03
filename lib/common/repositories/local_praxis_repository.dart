import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/repositories/praxis_repository.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/schedule_service.dart';
import 'package:praxis/common/services/xp_service.dart';

class LocalPraxisRepository implements PraxisRepository {
  @override
  UserProfile getProfile() => DatabaseService.getUserProfile();

  @override
  List<Goal> getGoals() => DatabaseService.getAllGoals();

  @override
  List<Project> getProjects() => DatabaseService.getAllProjects();

  @override
  List<XpEvent> getRecentXpEvents({int limit = 4}) =>
      DatabaseService.getAllXpEvents().take(limit).toList();

  @override
  DailyReview? getDailyReviewByDate(DateTime date) =>
      DatabaseService.getDailyReviewByDate(date);

  @override
  List<Todo> getRecommendedTodosForToday({int limit = 5}) =>
      DatabaseService.getTopTodosForToday(limit: limit);

  @override
  List<TodoScheduleSlot> getTodaySchedule() =>
      DatabaseService.getScheduleSlotsForDate(DateTime.now());

  @override
  List<RewardTodo> getPendingRewardTodos() =>
      DatabaseService.getPendingRewardTodos();

  @override
  int getPraisePointsBalance() => DatabaseService.getPraisePointBalance();

  @override
  Future<void> refreshWeeklySchedule() async {
    await ScheduleService.ensureWeeklySchedule();
  }

  @override
  Future<void> toggleTodo(Todo todo) async {
    final wasDone = todo.isDone;
    todo.toggleDone();
    await DatabaseService.updateTodo(todo);
    if (!wasDone && todo.isDone) {
      await XpService.awardTodoCompleted(todo);
    }
  }
}
