// lib/common/ai/services/zx_ai_service.dart
// ZhiXing AI增强服务 - 智能任务分解和规划（使用zx缩写）

import 'dart:convert';

import 'package:get/get.dart';
import 'package:zx/common/ai/services/ai_service.dart';

class ZxAIService extends GetxService {
  final AiService _aiService = AiService();
  
  // 智能任务分解
  Future<List<ZxTask>> decomposeGoalWithAI({
    required String goalTitle,
    String? description,
    int estimatedDays = 30,
  }) async {
    try {
      final prompt = _buildTaskDecompositionPrompt(
        goalTitle: goalTitle,
        description: description,
        estimatedDays: estimatedDays,
      );
      
      final response = await _aiService.sendMessage(prompt);
      return _parseTasksFromAIResponse(response);
    } catch (e) {
      print('AI任务分解失败: $e');
      return [];
    }
  }
  
  // 智能时间规划
  Future<List<ZxTimeSlot>> smartScheduleTasks({
    required List<ZxTask> tasks,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final prompt = _buildSchedulingPrompt(
        tasks: tasks,
        startDate: startDate,
        endDate: endDate,
      );
      
      final response = await _aiService.sendMessage(prompt);
      return _parseScheduleFromAIResponse(response);
    } catch (e) {
      print('AI时间规划失败: $e');
      return [];
    }
  }
  
  // 智能优先级建议
  Future<List<ZxPrioritySuggestion>> suggestTaskPriorities({
    required List<ZxTask> tasks,
    Map<String, dynamic>? context,
  }) async {
    try {
      final prompt = _buildPrioritySuggestionPrompt(tasks, context);
      final response = await _aiService.sendMessage(prompt);
      return _parsePrioritiesFromAIResponse(response);
    } catch (e) {
      print('AI优先级建议失败: $e');
      return [];
    }
  }
  
  // 智能进度跟踪
  Future<ZxProgressAnalysis> analyzeProgress({
    required List<ZxTask> completedTasks,
    required List<ZxTask> pendingTasks,
    DateTime? startDate,
  }) async {
    try {
      final prompt = _buildProgressAnalysisPrompt(
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        startDate: startDate,
      );
      
      final response = await _aiService.sendMessage(prompt);
      return _parseProgressAnalysisFromAIResponse(response);
    } catch (e) {
      print('AI进度分析失败: $e');
      return ZxProgressAnalysis.empty();
    }
  }
  
  // 智能习惯养成建议
  Future<List<ZxHabitSuggestion>> suggestHabits({
    required String goal,
    required List<String> completedTasks,
  }) async {
    try {
      final prompt = _buildHabitSuggestionPrompt(goal, completedTasks);
      final response = await _aiService.sendMessage(prompt);
      return _parseHabitSuggestionsFromAIResponse(response);
    } catch (e) {
      print('AI习惯建议失败: $e');
      return [];
    }
  }
  
  // 生成智能提醒
  Future<List<ZxSmartReminder>> generateSmartReminders({
    required List<ZxTask> tasks,
    required DateTime currentTime,
  }) async {
    try {
      final prompt = _buildReminderGenerationPrompt(tasks, currentTime);
      final response = await _aiService.sendMessage(prompt);
      return _parseRemindersFromAIResponse(response);
    } catch (e) {
      print('AI提醒生成失败: $e');
      return [];
    }
  }
  
  // 构建任务分解提示
  String _buildTaskDecompositionPrompt({
    required String goalTitle,
    String? description,
    int estimatedDays = 30,
  }) {
    return '''
请为以下目标制定详细的执行计划：

目标：$goalTitle
描述：${description ?? '无'}
预计完成时间：${estimatedDays}天

请将目标分解为具体的、可执行的任务，要求：
1. 每个任务都应该具体、可衡量、可达成
2. 按照逻辑顺序排列，考虑依赖关系
3. 为每个任务提供优先级（高/中/低）
4. 提供时间估算（小时或天）
5. 建议相关的标签

请严格按照以下JSON格式返回：
{
  "tasks": [
    {
      "title": "任务标题",
      "description": "任务详细描述",
      "priority": "high|medium|low",
      "estimatedTime": "时间估算",
      "dependencies": ["依赖任务ID"],
      "tags": ["相关标签"],
      "smartTips": "智能提示"
    }
  ],
  "overallStrategy": "整体执行策略",
  "keyMilestones": ["关键里程碑"]
}

请确保返回的是有效的JSON格式。
''';
  }
  
  // 构建时间规划提示
  String _buildSchedulingPrompt({
    required List<ZxTask> tasks,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final tasksJson = tasks.map((task) => '''
{
  "id": "${task.id}",
  "title": "${task.title}",
  "priority": "${task.priority}",
  "estimatedTime": "${task.estimatedTime}",
  "dependencies": [${task.dependencies.map((dep) => '"$dep"').join(',')}]
}''').join(',\n');
    
    return '''
请为以下任务制定详细的时间安排：

时间段：${startDate.toString().split(' ')[0]} 到 ${endDate.toString().split(' ')[0]}

任务列表：
$tasksJson

请考虑以下因素：
1. 任务优先级和紧急程度
2. 任务之间的依赖关系
3. 用户的工作效率模式
4. 合理的休息时间安排

请返回JSON格式：
{
  "schedule": [
    {
      "taskId": "任务ID",
      "startTime": "开始时间 (ISO 8601格式)",
      "endTime": "结束时间 (ISO 8601格式)",
      "duration": "实际用时",
      "tips": "执行建议"
    }
  ],
  "recommendations": [
    "总体建议1",
    "总体建议2"
  ]
}
''';
  }
  
  // 构建优先级建议提示
  String _buildPrioritySuggestionPrompt(
    List<ZxTask> tasks,
    Map<String, dynamic>? context,
  ) {
    final tasksJson = tasks.map((task) => '''
{
  "title": "${task.title}",
  "description": "${task.description}",
  "estimatedTime": "${task.estimatedTime}",
  "dueDate": "${task.dueDate}",
  "dependencies": [${task.dependencies.map((dep) => '"$dep"').join(',')}]
}''').join(',\n');
    
    return '''
请分析以下任务的优先级，建议合理的执行顺序：

任务列表：
$tasksJson

上下文信息：${context ?? '无'}

请根据以下原则进行分析：
1. 紧急且重要的任务优先
2. 考虑截止日期的影响
3. 任务依赖关系
4. 完成任务的收益

返回格式：
{
  "suggestions": [
    {
      "taskId": "任务ID",
      "suggestedPriority": "high|medium|low",
      "reason": "优先级建议理由",
      "executionOrder": 1
    }
  ],
  "overallStrategy": "整体优先级策略"
}
''';
  }
  
  // 构建进度分析提示
  String _buildProgressAnalysisPrompt({
    required List<ZxTask> completedTasks,
    required List<ZxTask> pendingTasks,
    DateTime? startDate,
  }) {
    final completedJson = completedTasks.map((task) => '"${task.title}"').join(', ');
    final pendingJson = pendingTasks.map((task) => '"${task.title}"').join(', ');
    
    return '''
请分析以下项目进度情况：

开始时间：${startDate?.toString().split(' ')[0] ?? '未设置'}

已完成任务：[$completedJson]

待完成任务：[$pendingJson]

请分析：
1. 整体完成进度
2. 执行效率评估
3. 可能的风险和障碍
4. 改进建议
5. 预计完成时间

返回格式：
{
  "completionRate": 0.75,
  "efficiency": "良好|一般|需改进",
  "progress": "ahead|onTrack|behind",
  "risks": [
    {
      "description": "风险描述",
      "impact": "low|medium|high",
      "mitigation": "缓解措施"
    }
  ],
  "recommendations": [
    "建议1",
    "建议2"
  ],
  "estimatedCompletionDate": "预计完成日期"
}
''';
  }
  
  // 构建习惯建议提示
  String _buildHabitSuggestionPrompt(String goal, List<String> completedTasks) {
    final tasksJson = completedTasks.map((task) => '"$task"').join(', ');
    
    return '''
基于以下信息，建议有助于达成目标的好习惯：

目标：$goal
已完成的关键任务：[$tasksJson]

请分析：
1. 成功完成任务中体现出的良好习惯
2. 可以强化的行为模式
3. 需要培养的新习惯
4. 习惯养成的具体方法

返回格式：
{
  "habits": [
    {
      "name": "习惯名称",
      "description": "习惯描述",
      "frequency": "daily|weekly",
      "duration": "建议持续时间",
      "benefits": "养成后的好处",
      "implementationTips": "实施建议"
    }
  ],
  "successFactors": [
    "成功因素1",
    "成功因素2"
  ]
}
''';
  }
  
  // 构建智能提醒提示
  String _buildReminderGenerationPrompt(List<ZxTask> tasks, DateTime currentTime) {
    final tasksJson = tasks.map((task) => '''
{
  "title": "${task.title}",
  "priority": "${task.priority}",
  "dueDate": "${task.dueDate}",
  "estimatedTime": "${task.estimatedTime}"
}''').join(',\n');
    
    return '''
基于当前任务和时间，生成智能提醒建议：

当前时间：${currentTime.toString()}

任务列表：
$tasksJson

请生成：
1. 今日重点任务提醒
2. 截止日期提醒
3. 时间安排提醒
4. 习惯养成提醒

返回格式：
{
  "reminders": [
    {
      "type": "task|habit|deadline|schedule",
      "title": "提醒标题",
      "message": "提醒内容",
      "scheduledTime": "提醒时间",
      "priority": "high|medium|low",
      "recurring": false,
      "reason": "设置理由"
    }
  ],
  "smartSuggestions": [
    "智能建议1",
    "智能建议2"
  ]
}
''';
  }
  
  // 解析AI响应 - 智能任务分解
  List<ZxTask> _parseTasksFromAIResponse(String response) {
    try {
      final dynamic data = jsonDecode(response);
      if (data is! Map<String, dynamic>) return [];

      final tasksData = data['tasks'];
      if (tasksData is! List) return [];

      return List<ZxTask>.generate(tasksData.length, (index) {
        final item = tasksData[index];
        if (item is! Map<String, dynamic>) {
          return ZxTask(id: '$index', title: '未命名任务');
        }

        final id = (item['id'] ?? '$index').toString();
        final title = (item['title'] ?? '未命名任务').toString();
        final description = (item['description'] ?? '').toString();
        final priority = (item['priority'] ?? 'medium').toString();
        final estimatedTime = (item['estimatedTime'] ?? '').toString();

        final dependencies = (item['dependencies'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];
        final tags = (item['tags'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const <String>[];

        DateTime? dueDate;
        final due = item['dueDate'];
        if (due is String && due.isNotEmpty) {
          try {
            dueDate = DateTime.parse(due);
          } catch (_) {
            dueDate = null;
          }
        }

        return ZxTask(
          id: id,
          title: title,
          description: description,
          priority: priority,
          estimatedTime: estimatedTime,
          dependencies: dependencies,
          tags: tags,
          dueDate: dueDate,
        );
      });
    } catch (_) {
      return [];
    }
  }
  
  // 解析AI响应 - 时间规划
  List<ZxTimeSlot> _parseScheduleFromAIResponse(String response) {
    try {
      final dynamic data = jsonDecode(response);
      if (data is! Map<String, dynamic>) return [];

      final scheduleData = data['schedule'];
      if (scheduleData is! List) return [];

      return scheduleData.map<ZxTimeSlot>((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid schedule item');
        }

        final taskId = (item['taskId'] ?? '').toString();
        final startStr = (item['startTime'] ?? '').toString();
        final endStr = (item['endTime'] ?? '').toString();
        final duration = (item['duration'] ?? '').toString();
        final tips = (item['tips'] ?? '').toString();

        DateTime startTime;
        DateTime endTime;
        try {
          startTime = DateTime.parse(startStr);
          endTime = DateTime.parse(endStr);
        } catch (_) {
          final now = DateTime.now();
          startTime = now;
          endTime = now.add(const Duration(hours: 1));
        }

        return ZxTimeSlot(
          taskId: taskId,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
          tips: tips,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
  
  // 解析AI响应 - 优先级建议
  List<ZxPrioritySuggestion> _parsePrioritiesFromAIResponse(String response) {
    try {
      final dynamic data = jsonDecode(response);
      if (data is! Map<String, dynamic>) return [];

      final suggestions = data['suggestions'];
      if (suggestions is! List) return [];

      return suggestions.map<ZxPrioritySuggestion>((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid suggestion item');
        }

        final taskId = (item['taskId'] ?? '').toString();
        final suggestedPriority =
            (item['suggestedPriority'] ?? 'medium').toString();
        final reason = (item['reason'] ?? '').toString();
        final executionOrder =
            int.tryParse(item['executionOrder']?.toString() ?? '0') ?? 0;

        return ZxPrioritySuggestion(
          taskId: taskId,
          suggestedPriority: suggestedPriority,
          reason: reason,
          executionOrder: executionOrder,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
  
  // 解析AI响应 - 进度分析
  ZxProgressAnalysis _parseProgressAnalysisFromAIResponse(String response) {
    try {
      final dynamic data = jsonDecode(response);
      if (data is! Map<String, dynamic>) return ZxProgressAnalysis.empty();

      final completionRate =
          (data['completionRate'] as num?)?.toDouble() ?? 0.0;
      final efficiency = (data['efficiency'] ?? '一般').toString();
      final progress = (data['progress'] ?? 'onTrack').toString();

      final risksData = data['risks'];
      final risks = (risksData is List)
          ? risksData.map<ZxRisk>((item) {
              if (item is! Map<String, dynamic>) {
                throw const FormatException('Invalid risk item');
              }
              return ZxRisk(
                description: (item['description'] ?? '').toString(),
                impact: (item['impact'] ?? '').toString(),
                mitigation: (item['mitigation'] ?? '').toString(),
              );
            }).toList()
          : <ZxRisk>[];

      final recommendationsData = data['recommendations'];
      final recommendations = (recommendationsData is List)
          ? recommendationsData.map((e) => e.toString()).toList()
          : <String>[];

      DateTime? estimatedCompletionDate;
      final dateStr = data['estimatedCompletionDate'];
      if (dateStr is String && dateStr.isNotEmpty) {
        try {
          estimatedCompletionDate = DateTime.parse(dateStr);
        } catch (_) {
          estimatedCompletionDate = null;
        }
      }

      return ZxProgressAnalysis(
        completionRate: completionRate,
        efficiency: efficiency,
        progress: progress,
        risks: risks,
        recommendations: recommendations,
        estimatedCompletionDate: estimatedCompletionDate,
      );
    } catch (_) {
      return ZxProgressAnalysis.empty();
    }
  }
  
  // 解析AI响应 - 习惯建议
  List<ZxHabitSuggestion> _parseHabitSuggestionsFromAIResponse(
    String response,
  ) {
    try {
      final dynamic data = jsonDecode(response);
      if (data is! Map<String, dynamic>) return [];

      final habitsData = data['habits'];
      if (habitsData is! List) return [];

      return habitsData.map<ZxHabitSuggestion>((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid habit item');
        }

        return ZxHabitSuggestion(
          name: (item['name'] ?? '').toString(),
          description: (item['description'] ?? '').toString(),
          frequency: (item['frequency'] ?? '').toString(),
          duration: (item['duration'] ?? '').toString(),
          benefits: (item['benefits'] ?? '').toString(),
          implementationTips: (item['implementationTips'] ?? '').toString(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
  
  // 解析AI响应 - 智能提醒
  List<ZxSmartReminder> _parseRemindersFromAIResponse(String response) {
    try {
      final dynamic data = jsonDecode(response);
      if (data is! Map<String, dynamic>) return [];

      final remindersData = data['reminders'];
      if (remindersData is! List) return [];

      return remindersData.map<ZxSmartReminder>((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid reminder item');
        }

        final scheduled = (item['scheduledTime'] ?? '').toString();
        DateTime scheduledTime;
        try {
          scheduledTime = DateTime.parse(scheduled);
        } catch (_) {
          scheduledTime = DateTime.now();
        }

        return ZxSmartReminder(
          type: (item['type'] ?? '').toString(),
          title: (item['title'] ?? '').toString(),
          message: (item['message'] ?? '').toString(),
          scheduledTime: scheduledTime,
          priority: (item['priority'] ?? 'medium').toString(),
          recurring: item['recurring'] == true,
          reason: (item['reason'] ?? '').toString(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}

// AI相关数据模型（使用zx前缀）
class ZxTask {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String estimatedTime;
  final List<String> dependencies;
  final List<String> tags;
  final DateTime? dueDate;
  
  ZxTask({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.estimatedTime = '1小时',
    this.dependencies = const [],
    this.tags = const [],
    this.dueDate,
  });
}

class ZxTimeSlot {
  final String taskId;
  final DateTime startTime;
  final DateTime endTime;
  final String duration;
  final String tips;
  
  ZxTimeSlot({
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.tips = '',
  });
}

class ZxPrioritySuggestion {
  final String taskId;
  final String suggestedPriority;
  final String reason;
  final int executionOrder;
  
  ZxPrioritySuggestion({
    required this.taskId,
    required this.suggestedPriority,
    required this.reason,
    required this.executionOrder,
  });
}

class ZxProgressAnalysis {
  final double completionRate;
  final String efficiency;
  final String progress;
  final List<ZxRisk> risks;
  final List<String> recommendations;
  final DateTime? estimatedCompletionDate;
  
  ZxProgressAnalysis({
    required this.completionRate,
    required this.efficiency,
    required this.progress,
    required this.risks,
    required this.recommendations,
    this.estimatedCompletionDate,
  });
  
  factory ZxProgressAnalysis.empty() => ZxProgressAnalysis(
    completionRate: 0.0,
    efficiency: '一般',
    progress: 'onTrack',
    risks: [],
    recommendations: [],
  );
}

class ZxRisk {
  final String description;
  final String impact;
  final String mitigation;
  
  ZxRisk({
    required this.description,
    required this.impact,
    required this.mitigation,
  });
}

class ZxHabitSuggestion {
  final String name;
  final String description;
  final String frequency;
  final String duration;
  final String benefits;
  final String implementationTips;
  
  ZxHabitSuggestion({
    required this.name,
    required this.description,
    required this.frequency,
    required this.duration,
    required this.benefits,
    required this.implementationTips,
  });
}

class ZxSmartReminder {
  final String type;
  final String title;
  final String message;
  final DateTime scheduledTime;
  final String priority;
  final bool recurring;
  final String reason;
  
  ZxSmartReminder({
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledTime,
    required this.priority,
    required this.recurring,
    required this.reason,
  });
}

