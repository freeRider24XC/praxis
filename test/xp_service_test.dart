import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
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
    );
    await DatabaseService.addTodo(todo);

    final beforeXp = DatabaseService.getUserProfile().totalXp;
    await XpService.awardTodoCompleted(todo);

    final afterProfile = DatabaseService.getUserProfile();
    final events = DatabaseService.getAllXpEvents();

    expect(afterProfile.totalXp, beforeXp + XpService.todoCompletedXp);
    expect(events.first.source, 'todo_completed');
    expect(events.first.sourceId, todo.id);
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
