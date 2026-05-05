import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:praxis/common/ai/services/ai_use_case_service.dart';
import 'package:praxis/common/ai/services/ai_config_service.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

Future<void> _initDb() async {
  SharedPreferences.setMockInitialValues({});
  final tempDir = path.join(
    Directory.systemTemp.path,
    'praxis_ai_test_${DateTime.now().microsecondsSinceEpoch}',
  );
  await DatabaseService.init(hivePath: tempDir);
  await DatabaseService.clearAllData();
}

void main() {
  test('parses structured goal plan json', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    const raw = '''
{
  "domain": "职业发展",
  "goal": {
    "title": "完成作品集",
    "description": "三个月内完成作品集",
    "targetDate": "2026-08-31"
  },
  "milestones": ["整理案例", "完成首页"],
  "project": {
    "name": "作品集项目",
    "description": "作品集搭建"
  },
  "todos": [
    {"title": "列出 3 个案例", "description": "今天先把素材列出来", "dueDate": "2026-05-06", "priority": "high"}
  ],
  "followUpQuestions": []
}
''';

    final draft = AiSchemaParser.parseGoalPlan(
      raw,
      fallbackDomainId: domain.id,
    );

    expect(draft.goal.title, '完成作品集');
    expect(draft.project.name, '作品集项目');
    expect(draft.todos.length, 1);
    expect(draft.todos.first.domainId, draft.domainId);
  });

  test('parses review feedback json', () {
    const raw = '''
{
  "summary": "今天推进得不错",
  "focus": "明天先完成最关键的一步"
}
''';
    final feedback = AiSchemaParser.parseReviewFeedback(raw);
    expect(feedback.summary, '今天推进得不错');
    expect(feedback.focus, '明天先完成最关键的一步');
  });

  test('returns mock suggestion when ai is not configured', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    final profile = DatabaseService.getUserProfile();
    profile.focusedDomainId = domain.id;
    await DatabaseService.saveUserProfile(profile);

    final result = await AiUseCaseService().suggestTodayPlan();

    expect(result.isMock, true);
    expect(result.content.isNotEmpty, true);
  });

  test('parses json embedded in explanatory text', () async {
    await _initDb();
    final domain = DatabaseService.getAllLifeDomains().first;
    const raw = '''
这里是规划结果：
{
  "domain": "职业发展",
  "goal": {
    "title": "完成 Flutter MVP",
    "description": "两周内完成可验收版本",
    "targetDate": "2026-05-20"
  },
  "milestones": ["跑通主链路"],
  "project": {
    "name": "Flutter MVP 冲刺",
    "description": "集中完成 MVP"
  },
  "todos": [
    {"title": "修复 AI 规划流程", "priority": "high"}
  ],
  "followUpQuestions": []
}
''';

    final draft = AiSchemaParser.parseGoalPlan(
      raw,
      fallbackDomainId: domain.id,
    );

    expect(draft.goal.title, '完成 Flutter MVP');
    expect(draft.project.name, 'Flutter MVP 冲刺');
    expect(draft.todos.single.title, '修复 AI 规划流程');
  });

  test('detects provider kind from base url', () {
    expect(
      AiConfigService.detectProviderKind('https://api.openai.com/v1'),
      AiProviderKind.openai,
    );
    expect(
      AiConfigService.detectProviderKind('https://api.deepseek.com/v1'),
      AiProviderKind.deepseek,
    );
    expect(
      AiConfigService.detectProviderKind('https://api.minimax.chat/v1'),
      AiProviderKind.minimax,
    );
  });
}
