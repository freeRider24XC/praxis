import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _initDb() async {
  SharedPreferences.setMockInitialValues({});
  final tempDir = path.join(
    Directory.systemTemp.path,
    'praxis_xp_test_${DateTime.now().microsecondsSinceEpoch}',
  );
  await DatabaseService.init(hivePath: tempDir);
  await DatabaseService.clearAllData();
}

void main() {
  test('awarding todo completion increases xp and creates xp event', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    final todo = Todo(
      title: '测试任务',
      domainId: domain.id,
      isDone: true,
      completedAt: DateTime.now(),
      importanceLevel: ImportanceLevel.medium,
      difficultyLevel: DifficultyLevel.medium,
      priority: TodoPriority.medium,
    );
    await DatabaseService.addTodo(todo);

    final beforeXp = DatabaseService.getUserProfile().totalXp;
    final beforePraise = DatabaseService.getUserProfile().praisePointsBalance;
    await XpService.awardTodoCompleted(todo);

    final afterProfile = DatabaseService.getUserProfile();
    final events = DatabaseService.getAllXpEvents();
    final savedTodo = DatabaseService.getTodoById(todo.id);

    expect(afterProfile.totalXp, beforeXp + XpService.todoCompletedXp);
    expect(events.first.source, 'todo_completed');
    expect(events.first.sourceId, todo.id);
    // 三维度都是 medium 时，公式 = 4 × 1.0 × 1.0 × 1.0 = 4
    expect(savedTodo?.praisePointsEarned, 4);
    expect(afterProfile.praisePointsBalance, beforePraise + 4);
  });

  test('awarding high-importance todo credits higher praise points', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    final todo = Todo(
      title: '关键任务',
      domainId: domain.id,
      isDone: true,
      completedAt: DateTime.now(),
      importanceLevel: ImportanceLevel.high,
      difficultyLevel: DifficultyLevel.high,
      priority: TodoPriority.urgent,
    );
    await DatabaseService.addTodo(todo);

    await XpService.awardTodoCompleted(todo);

    final profile = DatabaseService.getUserProfile();
    final savedTodo = DatabaseService.getTodoById(todo.id);
    // 4 × 1.4 × 1.4 × 1.2 = 9.408 → clamp 8 → 8
    expect(savedTodo?.praisePointsEarned, 8);
    expect(profile.praisePointsBalance, 8);
  });

  test('awarding low-importance todo respects min clamp', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    final todo = Todo(
      title: '杂事',
      domainId: domain.id,
      isDone: true,
      completedAt: DateTime.now(),
      importanceLevel: ImportanceLevel.low,
      difficultyLevel: DifficultyLevel.low,
      priority: TodoPriority.low,
    );
    await DatabaseService.addTodo(todo);

    await XpService.awardTodoCompleted(todo);

    final savedTodo = DatabaseService.getTodoById(todo.id);
    // 4 × 0.8 × 0.9 × 0.9 = 2.592 → round = 3
    expect(savedTodo?.praisePointsEarned, 3);
  });

  test('awarding daily review updates streak and xp once', () async {
    await _initDb();
    final review = DailyReview(
      date: DateTime.now(),
      whatDone: '完成测试',
      blockers: '无',
      topPriorityTomorrow: '继续测试',
      isCompleted: true,
    );

    await DatabaseService.upsertDailyReview(review);
    await XpService.awardDailyReview(review);

    final profile = DatabaseService.getUserProfile();
    expect(profile.totalXp, XpService.dailyReviewXp);
    expect(profile.streakDays, 1);
  });
}
