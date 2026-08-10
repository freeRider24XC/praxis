import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/praise_points_calculator.dart';
import 'package:praxis/common/services/profile_service.dart';

class XpService {
  static const int todoCompletedXp = 10;
  static const int goalCompletedXp = 100;
  static const int dailyReviewXp = 20;

  static int levelForXp(int xp) {
    var level = 1;
    var remaining = xp;
    while (remaining >= xpNeededForNextLevel(level)) {
      remaining -= xpNeededForNextLevel(level);
      level += 1;
    }
    return level;
  }

  static int xpNeededForNextLevel(int level) {
    return 100 + (level * 50);
  }

  static int currentLevelStartXp(int level) {
    var xp = 0;
    for (var current = 1; current < level; current++) {
      xp += xpNeededForNextLevel(current);
    }
    return xp;
  }

  static int xpIntoCurrentLevel(int totalXp) {
    final level = levelForXp(totalXp);
    return totalXp - currentLevelStartXp(level);
  }

  static int xpNeededWithinCurrentLevel(int totalXp) {
    return xpNeededForNextLevel(levelForXp(totalXp));
  }

  static Future<void> awardTodoCompleted(Todo todo) async {
    await _awardXp(
      xp: todoCompletedXp,
      source: 'todo_completed',
      sourceId: todo.id,
      domainId: todo.domainId,
      description: '完成任务：${todo.title}',
      markActiveAt: todo.completedAt ?? DateTime.now(),
    );

    // 结算并发放犒赏点：写入 Todo 自身记录 + 累计到 Profile 余额。
    final praisePoints = PraisePointsCalculator.forTodo(todo);
    if (praisePoints > 0) {
      todo.praisePointsEarned = praisePoints;
      await todo.save();
      await ProfileService.incrementPraisePoints(praisePoints);
    }
  }

  static Future<void> awardGoalCompleted(Goal goal) async {
    await _awardXp(
      xp: goalCompletedXp,
      source: 'goal_completed',
      sourceId: goal.id,
      domainId: goal.domainId,
      description: '完成目标：${goal.title}',
      markActiveAt: DateTime.now(),
    );
  }

  static Future<void> awardDailyReview(DailyReview review) async {
    await _awardXp(
      xp: dailyReviewXp,
      source: 'daily_review',
      sourceId: review.id,
      domainId: DatabaseService.getUserProfile().focusedDomainId,
      description: '完成每日复盘',
      markActiveAt: review.date,
    );
  }

  static Future<void> _awardXp({
    required int xp,
    required String source,
    required String sourceId,
    required String? domainId,
    required String description,
    required DateTime markActiveAt,
  }) async {
    final profile = DatabaseService.getUserProfile();
    profile.totalXp += xp;
    profile.level = levelForXp(profile.totalXp);
    profile.updatedAt = DateTime.now();
    await DatabaseService.saveUserProfile(profile);

    await DatabaseService.addXpEvent(
      XpEvent(
        xp: xp,
        source: source,
        sourceId: sourceId,
        domainId: domainId,
        description: description,
      ),
    );

    await ProfileService.markActiveForDate(markActiveAt);
  }
}
