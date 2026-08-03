import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/reward_service.dart';
import 'package:praxis/common/services/schedule_service.dart';
import 'package:praxis/common/services/xp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _initDb() async {
  SharedPreferences.setMockInitialValues({});
  final tempDir = path.join(
    Directory.systemTemp.path,
    'praxis_reward_schedule_test_${DateTime.now().microsecondsSinceEpoch}',
  );
  await DatabaseService.init(hivePath: tempDir);
  await DatabaseService.clearAllData();
  await RewardService.ensureSeededTemplates();
}

void main() {
  test('completing a todo awards praise points', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    final todo = Todo(
      title: '完成最小行动',
      domainId: domain.id,
      isDone: true,
      completedAt: DateTime.now(),
    );
    await DatabaseService.addTodo(todo);

    await XpService.awardTodoCompleted(todo);

    expect(DatabaseService.getPraisePointBalance(), 1);
    expect(DatabaseService.getAllPraisePointLedgers().first.delta, 1);
  });

  test('redeeming a reward creates a reward todo', () async {
    await _initDb();
    final template = DatabaseService.getRewardTemplates().first;
    await DatabaseService.addPraisePointLedger(
      PraisePointLedger(
        delta: template.priceInPraisePoints,
        source: PraisePointSource.todoCompleted,
        sourceId: 'seed',
        description: '测试充值',
      ),
    );

    await RewardService.redeemReward(template);

    expect(DatabaseService.getPendingRewardTodos().length, 1);
    expect(DatabaseService.getPraisePointBalance(), 0);
  });

  test('weekly schedule generation creates slots for open todos', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    await DatabaseService.addTodo(Todo(title: '事项一', domainId: domain.id));
    await DatabaseService.addTodo(Todo(title: '事项二', domainId: domain.id));

    await ScheduleService.ensureWeeklySchedule();

    expect(DatabaseService.getScheduleSlotsBetween(
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now().add(const Duration(days: 7)),
    ).isNotEmpty, true);
  });

  test('blueprint structure normalizes project goal links and todo ownership', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    final goal = Goal(
      title: '上线公开体验版',
      type: GoalType.quarterly,
      targetDate: DateTime.now().add(const Duration(days: 90)),
      domainId: domain.id,
    );
    await DatabaseService.addGoal(goal);

    final project = Project(
      name: '公开发布项目',
      goalIds: [goal.id, 'legacy-goal-id'],
      domainId: domain.id,
    );
    await DatabaseService.addProject(project);

    final todo = Todo(
      title: '补 landing 页',
      goalId: goal.id,
      domainId: domain.id,
    );
    await DatabaseService.addTodo(todo);

    final storedProject = DatabaseService.getProjectById(project.id)!;
    final storedTodo = DatabaseService.getTodoById(todo.id)!;

    expect(storedProject.goalIds, [goal.id]);
    expect(storedTodo.projectId, isNotNull);
    expect(storedTodo.goalId, goal.id);
    expect(DatabaseService.getProjectsByGoal(goal.id).isNotEmpty, true);
  });
}
