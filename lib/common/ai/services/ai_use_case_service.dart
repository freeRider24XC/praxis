import 'dart:convert';

import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/ai/services/ai_config_service.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/domain_service.dart';

class AiGoalPlanDraft {
  final String domainId;
  final Goal goal;
  final Project project;
  final List<String> milestones;
  final List<Todo> todos;
  final List<String> followUpQuestions;
  final bool isMock;

  AiGoalPlanDraft({
    required this.domainId,
    required this.goal,
    required this.project,
    required this.milestones,
    required this.todos,
    required this.followUpQuestions,
    required this.isMock,
  });
}

class AiReviewFeedback {
  final String summary;
  final String focus;
  final bool isMock;

  AiReviewFeedback({
    required this.summary,
    required this.focus,
    required this.isMock,
  });
}

class AiSuggestionResult {
  final String content;
  final bool isMock;

  AiSuggestionResult({
    required this.content,
    required this.isMock,
  });
}

class AiUseCaseService {
  AiUseCaseService({OpenAIProvider? provider})
      : _provider = provider ?? OpenAIProvider();

  final OpenAIProvider _provider;

  Future<AiGoalPlanDraft> planGoal({
    required String goalText,
    required String focusedDomainId,
    required int weeklyCapacityHours,
  }) async {
    final fallback = _buildMockGoalPlan(
      goalText: goalText,
      focusedDomainId: focusedDomainId,
      weeklyCapacityHours: weeklyCapacityHours,
    );

    if (!await _provider.isConfigured()) {
      return fallback;
    }

    final focusedDomain = DomainService.getDomainById(focusedDomainId);
    if (focusedDomain == null) {
      return fallback;
    }

    final prompt = '''
请根据以下目标，输出严格 JSON，不要包含 markdown，不要包含代码块，不要包含解释。

当前重点领域：${focusedDomain.name}
每周可投入时长：$weeklyCapacityHours 小时
用户目标：$goalText

输出格式：
{
  "domain": "职业发展/健康身体/财务管理/人际关系/成长学习",
  "goal": {
    "title": "目标标题",
    "description": "一句话描述",
    "targetDate": "YYYY-MM-DD"
  },
  "milestones": ["里程碑1", "里程碑2"],
  "project": {
    "name": "项目名称",
    "description": "项目描述"
  },
  "todos": [
    {
      "title": "任务标题",
      "description": "任务说明",
      "dueDate": "YYYY-MM-DD",
      "priority": "high/medium/low"
    }
  ],
  "followUpQuestions": []
}

要求：
- 输出 3 到 5 个本周任务
- 任务必须足够具体，可以在本周内执行
- 优先让任务具备“最小下一步”特征
- 如果信息足够，不要输出追问
''';

    try {
      final response = await _provider.structuredPlanningChat(prompt);
      return AiSchemaParser.parseGoalPlan(
        response,
        fallbackDomainId: focusedDomainId,
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<AiSuggestionResult> suggestTodayPlan() async {
    final focusedDomain = DomainService.getFocusedDomain();
    final todos = DatabaseService.getTopTodosForToday(limit: 3);
    final fallback = _buildMockTodaySuggestion(
      focusedDomain: focusedDomain,
      todos: todos,
    );

    if (!await _provider.isConfigured()) {
      return fallback;
    }

    final todoSummaries = todos
        .map((todo) => {
              'title': todo.title,
              'description': todo.description,
              'priority': todo.priority.name,
              'dueDate': todo.dueDate?.toIso8601String(),
            })
        .toList();

    final prompt = '''
请根据以下信息，输出一句简短的今日行动建议。返回严格 JSON。

{
  "focusedDomain": ${jsonEncode(focusedDomain?.name ?? '当前重点方向')},
  "todos": ${jsonEncode(todoSummaries)}
}

输出格式：
{
  "suggestion": "一句今日建议"
}

要求：
- 20 到 40 个中文字符
- 优先强调最重要的一步
- 不要使用 markdown，不要加编号
''';

    try {
      final response = await _provider.chat(prompt, const []);
      final data = AiSchemaParser._decodeObject(response);
      final suggestion = (data['suggestion'] as String?)?.trim();
      if (suggestion == null || suggestion.isEmpty) {
        return fallback;
      }
      return AiSuggestionResult(content: suggestion, isMock: false);
    } catch (_) {
      return fallback;
    }
  }

  Future<AiPlanAvailability> getAvailability() async {
    final configured = await AiConfigService.isConfigured();
    final provider =
        configured ? await AiConfigService.getProviderLabel() : null;
    return AiPlanAvailability(
      isConfigured: configured,
      providerLabel: provider,
    );
  }

  AiSuggestionResult _buildMockTodaySuggestion({
    required LifeDomain? focusedDomain,
    required List<Todo> todos,
  }) {
    if (todos.isEmpty) {
      return AiSuggestionResult(
        content: '今天先用 10 分钟整理目标，给自己一个清晰的下一步。',
        isMock: true,
      );
    }
    final lead = todos.first.title;
    final domainLabel = focusedDomain?.name ?? '当前重点方向';
    return AiSuggestionResult(
      content: '今天优先推进“$lead”，它会最直接带动你的$domainLabel进度。',
      isMock: true,
    );
  }

  Future<AiReviewFeedback> reviewDay({
    required DailyReview review,
  }) async {
    final fallback = _buildMockReview(review);

    if (!await _provider.isConfigured()) {
      return fallback;
    }

    final prompt = '''
请根据以下每日复盘，输出一条简短总结和一条明日建议。返回严格 JSON。

{
  "whatDone": ${jsonEncode(review.whatDone ?? '')},
  "blockers": ${jsonEncode(review.blockers ?? '')},
  "topPriorityTomorrow": ${jsonEncode(review.topPriorityTomorrow ?? '')}
}

输出格式：
{
  "summary": "一句总结",
  "focus": "一句明日建议"
}
''';

    try {
      final response = await _provider.chat(prompt, const []);
      return AiSchemaParser.parseReviewFeedback(response);
    } catch (_) {
      return fallback;
    }
  }

  AiGoalPlanDraft _buildMockGoalPlan({
    required String goalText,
    required String focusedDomainId,
    required int weeklyCapacityHours,
  }) {
    final domain = DomainService.getDomainById(focusedDomainId) ??
        DatabaseService.getAllLifeDomains().first;
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month + 2, now.day);
    final projectName = '$goalText 行动计划';
    final todos = List.generate(3, (index) {
      final dueDate = DateTime(now.year, now.month, now.day + index + 1);
      return Todo(
        title: _mockTodoTitle(goalText, index),
        description: '围绕“$goalText”的第${index + 1}个最小行动，按本周节奏推进。',
        dueDate: dueDate,
        priority: index == 0 ? TodoPriority.high : TodoPriority.medium,
        domainId: domain.id,
      );
    });

    return AiGoalPlanDraft(
      domainId: domain.id,
      goal: Goal(
        title: goalText,
        description: '在接下来 1-3 个月内稳定推进“$goalText”。',
        type: GoalType.monthly,
        targetDate: targetDate,
        milestones: [
          '明确起点与成功标准',
          '完成第一周连续推进',
          '完成一个可量化的小成果',
        ],
        domainId: domain.id,
      ),
      project: Project(
        name: projectName,
        description: '围绕目标“$goalText”的首轮执行项目。',
        color: domain.color,
        domainId: domain.id,
      ),
      milestones: const [
        '明确起点与成功标准',
        '完成第一周连续推进',
        '完成一个可量化的小成果',
      ],
      todos: todos,
      followUpQuestions:
          weeklyCapacityHours <= 3 ? ['你本周最容易挤出来的固定时间段是什么？'] : const [],
      isMock: true,
    );
  }

  String _mockTodoTitle(String goalText, int index) {
    const verbs = ['定义', '安排', '执行'];
    return '${verbs[index.clamp(0, verbs.length - 1)]}$goalText的第${index + 1}步';
  }

  AiReviewFeedback _buildMockReview(DailyReview review) {
    final completed = (review.whatDone ?? '').trim();
    final blocker = (review.blockers ?? '').trim();
    final tomorrow = (review.topPriorityTomorrow ?? '').trim();
    final summary = completed.isEmpty
        ? '今天的推进还不够明显，但你已经为明天的行动做了整理。'
        : '今天已经完成关键推进，说明你的节奏正在稳定下来。';
    final focus = tomorrow.isNotEmpty
        ? '明天只盯住“$tomorrow”，先完成这一件，再考虑别的事。'
        : (blocker.isNotEmpty
            ? '明天先解决“$blocker”带来的阻碍，把门槛降到最小。'
            : '明天先完成一个 20 分钟以内的最小行动，重新建立推进感。');
    return AiReviewFeedback(summary: summary, focus: focus, isMock: true);
  }
}

class AiPlanAvailability {
  final bool isConfigured;
  final String? providerLabel;

  AiPlanAvailability({
    required this.isConfigured,
    required this.providerLabel,
  });
}

class AiSchemaParser {
  static AiGoalPlanDraft parseGoalPlan(
    String raw, {
    required String fallbackDomainId,
  }) {
    final data = _decodeObject(raw);
    final domainName = (data['domain'] as String?)?.trim();
    final domain = _matchDomain(domainName) ??
        DatabaseService.getLifeDomainById(fallbackDomainId) ??
        DatabaseService.getAllLifeDomains().first;

    final goalData = (data['goal'] as Map?)?.cast<String, dynamic>() ?? {};
    final projectData =
        (data['project'] as Map?)?.cast<String, dynamic>() ?? {};
    final milestoneList = (data['milestones'] as List?)
            ?.map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList() ??
        <String>[];
    final todoList = (data['todos'] as List?) ?? const [];

    final goal = Goal(
      title: (goalData['title'] as String?)?.trim().isNotEmpty == true
          ? (goalData['title'] as String).trim()
          : '新的成长目标',
      description: (goalData['description'] as String?)?.trim(),
      type: GoalType.monthly,
      targetDate: _parseDate(goalData['targetDate'] as String?) ??
          DateTime.now().add(const Duration(days: 90)),
      milestones: milestoneList.isEmpty ? null : milestoneList,
      domainId: domain.id,
    );

    final project = Project(
      name: (projectData['name'] as String?)?.trim().isNotEmpty == true
          ? (projectData['name'] as String).trim()
          : '${goal.title} 项目',
      description: (projectData['description'] as String?)?.trim(),
      color: domain.color,
      domainId: domain.id,
    );

    final todos = todoList.map((item) {
      final todo = (item as Map).cast<String, dynamic>();
      return Todo(
        title: (todo['title'] as String?)?.trim().isNotEmpty == true
            ? (todo['title'] as String).trim()
            : '执行下一步行动',
        description: (todo['description'] as String?)?.trim(),
        dueDate: _parseDate(todo['dueDate'] as String?),
        priority: _parsePriority(todo['priority'] as String?),
        domainId: domain.id,
      );
    }).toList();

    final followUpQuestions = (data['followUpQuestions'] as List?)
            ?.map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList() ??
        <String>[];

    return AiGoalPlanDraft(
      domainId: domain.id,
      goal: goal,
      project: project,
      milestones: milestoneList,
      todos: todos,
      followUpQuestions: followUpQuestions,
      isMock: false,
    );
  }

  static AiReviewFeedback parseReviewFeedback(String raw) {
    final data = _decodeObject(raw);
    return AiReviewFeedback(
      summary: (data['summary'] as String?)?.trim().isNotEmpty == true
          ? (data['summary'] as String).trim()
          : '今天已经有了推进，继续维持这个节奏。',
      focus: (data['focus'] as String?)?.trim().isNotEmpty == true
          ? (data['focus'] as String).trim()
          : '明天先完成一件最小但明确的行动。',
      isMock: false,
    );
  }

  static Map<String, dynamic> _decodeObject(String raw) {
    final trimmed = raw.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('No JSON object found');
    }
    final jsonStr = trimmed.substring(start, end + 1);
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected an object');
    }
    return decoded;
  }

  static LifeDomain? _matchDomain(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    final domains = DatabaseService.getAllLifeDomains();
    return domains.cast<LifeDomain?>().firstWhere(
          (domain) =>
              domain != null &&
              (domain.name == name ||
                  name.contains(domain.name) ||
                  domain.name.contains(name)),
          orElse: () => null,
        );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return DateTime.parse(raw.trim());
    } catch (_) {
      return null;
    }
  }

  static TodoPriority _parsePriority(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'high':
      case 'urgent':
        return TodoPriority.high;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.medium;
    }
  }
}
