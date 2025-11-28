import 'dart:convert';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/models/project.dart';

class EntityExtractionResult {
  final String? action; // 'create_todo', 'create_goal', 'create_project'
  final Todo? todo;
  final Goal? goal;
  final Project? project;
  final List<Todo>? todos; // 用于批量创建
  final List<Project>? projects; // 用于批量创建项目
  final String? error;

  EntityExtractionResult({
    this.action,
    this.todo,
    this.goal,
    this.project,
    this.todos,
    this.projects,
    this.error,
  });

  bool get hasError => error != null;
  bool get hasTodo => todo != null;
  bool get hasGoal => goal != null;
  bool get hasProject => project != null;
  bool get hasTodos => todos != null && todos!.isNotEmpty;
  bool get hasProjects => projects != null && projects!.isNotEmpty;
}

class EntityExtractor {
  // 从AI回复中提取待办事项列表（纯文本格式）
  static EntityExtractionResult extractFromResponse(String response) {
    // 先尝试解析JSON格式（向后兼容）
    final jsonResult = _tryExtractJson(response);
    if (jsonResult != null && !jsonResult.hasError) {
      return jsonResult;
    }
    
    // 尝试从纯文本列表格式提取
    final textResult = _extractFromTextList(response);
    if (textResult != null && !textResult.hasError) {
      return textResult;
    }
    
    return EntityExtractionResult(error: '未能识别到待办事项');
  }

  // 尝试从文本列表格式提取
  static EntityExtractionResult? _extractFromTextList(String response) {
    try {
      final todos = <Todo>[];
      
      // 匹配格式：序号. 任务标题（截止日期：YYYY-MM-DD）[优先级：高/中/低]
      // 也支持：序号. 任务标题
      // 也支持：- 任务标题
      final lines = response.split('\n');
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;
        
        // 匹配序号格式：1. 2. 3. 或 - 
        final numberPattern = RegExp(r'^(\d+)[\.、]\s*(.+)$');
        final dashPattern = RegExp(r'^[-•]\s*(.+)$');
        
        String? taskText;
        Match? match;
        
        if (numberPattern.hasMatch(trimmedLine)) {
          match = numberPattern.firstMatch(trimmedLine);
          taskText = match?.group(2);
        } else if (dashPattern.hasMatch(trimmedLine)) {
          match = dashPattern.firstMatch(trimmedLine);
          taskText = match?.group(1);
        }
        
        if (taskText == null || taskText.isEmpty) continue;
        
        // 解析任务标题、截止日期和优先级
        String title = taskText;
        DateTime? dueDate;
        TodoPriority priority = TodoPriority.medium;
        
        // 提取截止日期：格式（截止日期：YYYY-MM-DD）或（截止：YYYY-MM-DD）
        // 也支持相对日期：（截止日期：明天）、（截止日期：下周）
        final datePattern = RegExp(r'（截止日期?：([^）]+)）');
        final dateMatch = datePattern.firstMatch(taskText);
        if (dateMatch != null) {
          final dateStr = dateMatch.group(1)!.trim();
          try {
            // 尝试解析标准日期格式
            if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
              dueDate = DateTime.parse(dateStr);
            } else {
              // 解析相对日期
              dueDate = _parseRelativeDate(dateStr);
            }
            // 从标题中移除日期部分
            title = taskText.replaceAll(datePattern, '').trim();
          } catch (_) {
            // 日期解析失败，忽略
          }
        }
        
        // 提取优先级：格式[优先级：高/中/低] 或 [高/中/低]
        final priorityPattern = RegExp(r'\[优先级?：?(高|中|低|high|medium|low)\]');
        final priorityMatch = priorityPattern.firstMatch(taskText);
        if (priorityMatch != null) {
          final priorityStr = priorityMatch.group(1)!.toLowerCase();
          switch (priorityStr) {
            case '高':
            case 'high':
              priority = TodoPriority.high;
              break;
            case '低':
            case 'low':
              priority = TodoPriority.low;
              break;
            case '中':
            case 'medium':
            default:
              priority = TodoPriority.medium;
          }
          // 从标题中移除优先级部分
          title = title.replaceAll(priorityPattern, '').trim();
        }
        
        // 清理标题中的多余空格和标点
        title = title.replaceAll(RegExp(r'^\s*[.、]\s*'), '').trim();
        
        if (title.isNotEmpty) {
          todos.add(Todo(
            title: title,
            priority: priority,
            dueDate: dueDate,
          ));
        }
      }
      
      if (todos.isEmpty) {
        return null;
      }
      
      return EntityExtractionResult(
        action: 'create_todo',
        todos: todos,
      );
    } catch (e) {
      return EntityExtractionResult(error: '解析文本列表失败: $e');
    }
  }

  // 尝试从JSON格式提取（向后兼容）
  static EntityExtractionResult? _tryExtractJson(String response) {
    try {
      // 尝试提取JSON（可能在代码块中或直接存在）
      String? jsonStr;
      
      // 检查是否有代码块
      if (response.contains('```json')) {
        final start = response.indexOf('```json') + 7;
        final end = response.indexOf('```', start);
        if (end != -1) {
          jsonStr = response.substring(start, end).trim();
        }
      } else if (response.contains('```')) {
        final start = response.indexOf('```') + 3;
        final end = response.indexOf('```', start);
        if (end != -1) {
          jsonStr = response.substring(start, end).trim();
        }
      } else {
        // 尝试找到JSON对象
        final jsonStart = response.indexOf('{');
        final jsonEnd = response.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          jsonStr = response.substring(jsonStart, jsonEnd + 1);
        }
      }

      if (jsonStr == null || jsonStr.isEmpty) {
        return null;
      }

      // 解析JSON
      final data = jsonDecode(jsonStr);
      
      // 检查是否为数组
      if (data is List) {
        final todos = <Todo>[];
        for (final item in data) {
          if (item is Map<String, dynamic> && item['action'] == 'create_todo') {
            final result = _extractTodo(item);
            if (result.hasTodo && result.todo != null) {
              todos.add(result.todo!);
            }
          }
        }
        if (todos.isNotEmpty) {
          return EntityExtractionResult(action: 'create_todo', todos: todos);
        }
      } else if (data is Map<String, dynamic>) {
        final action = data['action'] as String?;
        if (action == 'create_todo') {
          return _extractTodo(data);
        } else if (action == 'create_goal') {
          return _extractGoal(data);
        } else if (action == 'create_project') {
          return _extractProject(data);
        }
      }
      
      return EntityExtractionResult(error: '未找到有效的JSON数据');
    } catch (e) {
      return null; // JSON解析失败，返回null让文本解析处理
    }
  }

  // 提取Todo
  static EntityExtractionResult _extractTodo(Map<String, dynamic> data) {
    try {
      final title = data['title'] as String?;
      if (title == null || title.isEmpty) {
        return EntityExtractionResult(error: '任务标题不能为空');
      }

      final description = data['description'] as String?;
      final priorityStr = (data['priority'] as String?)?.toLowerCase() ?? 'medium';
      final dueDateStr = data['dueDate'] as String?;

      // 解析优先级
      TodoPriority priority;
      switch (priorityStr) {
        case 'high':
        case '紧急':
          priority = TodoPriority.high;
          break;
        case 'low':
        case '低':
          priority = TodoPriority.low;
          break;
        default:
          priority = TodoPriority.medium;
      }

      // 解析日期
      DateTime? dueDate;
      if (dueDateStr != null && dueDateStr.isNotEmpty) {
        try {
          dueDate = DateTime.parse(dueDateStr);
        } catch (_) {
          // 日期解析失败，使用null
        }
      }

      final todo = Todo(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );

      return EntityExtractionResult(action: 'create_todo', todo: todo);
    } catch (e) {
      return EntityExtractionResult(error: '创建待办事项失败: $e');
    }
  }

  // 提取Goal
  static EntityExtractionResult _extractGoal(Map<String, dynamic> data) {
    try {
      final title = data['title'] as String?;
      if (title == null || title.isEmpty) {
        return EntityExtractionResult(error: '目标标题不能为空');
      }

      final description = data['description'] as String?;
      final typeStr = (data['type'] as String?)?.toLowerCase() ?? 'month';
      final targetDateStr = data['targetDate'] as String?;

      // 解析目标类型
      GoalType type;
      switch (typeStr) {
        case 'year':
        case 'yearly':
        case '年':
          type = GoalType.yearly;
          break;
        case 'quarter':
        case 'quarterly':
        case '季度':
          type = GoalType.quarterly;
          break;
        case 'week':
        case 'weekly':
        case '周':
          type = GoalType.weekly;
          break;
        default:
          type = GoalType.monthly;
      }

      // 解析目标日期
      DateTime targetDate;
      if (targetDateStr != null && targetDateStr.isNotEmpty) {
        try {
          targetDate = DateTime.parse(targetDateStr);
        } catch (_) {
          // 日期解析失败，使用默认值（3个月后）
          targetDate = DateTime.now().add(const Duration(days: 90));
        }
      } else {
        // 没有指定日期，根据类型设置默认值
        final now = DateTime.now();
        switch (type) {
          case GoalType.yearly:
            targetDate = DateTime(now.year + 1, now.month, now.day);
            break;
          case GoalType.quarterly:
            targetDate = now.add(const Duration(days: 90));
            break;
          case GoalType.monthly:
            targetDate = DateTime(now.year, now.month + 1, now.day);
            break;
          case GoalType.weekly:
            targetDate = now.add(const Duration(days: 7));
            break;
          case GoalType.custom:
            targetDate = now.add(const Duration(days: 30));
            break;
        }
      }

      final goal = Goal(
        title: title,
        description: description,
        type: type,
        targetDate: targetDate,
      );

      return EntityExtractionResult(action: 'create_goal', goal: goal);
    } catch (e) {
      return EntityExtractionResult(error: '创建目标失败: $e');
    }
  }

  // 解析相对日期
  static DateTime? _parseRelativeDate(String dateStr) {
    final now = DateTime.now();
    final lowerStr = dateStr.toLowerCase();
    
    if (lowerStr.contains('今天') || lowerStr.contains('今日')) {
      return now;
    } else if (lowerStr.contains('明天') || lowerStr.contains('明日')) {
      return now.add(const Duration(days: 1));
    } else if (lowerStr.contains('后天')) {
      return now.add(const Duration(days: 2));
    } else if (lowerStr.contains('下周') || lowerStr.contains('下星期')) {
      return now.add(const Duration(days: 7));
    } else if (lowerStr.contains('下个月') || lowerStr.contains('下月')) {
      return DateTime(now.year, now.month + 1, now.day);
    }
    
    // 尝试解析数字+天/周/月
    final dayMatch = RegExp(r'(\d+)\s*天').firstMatch(lowerStr);
    if (dayMatch != null) {
      final days = int.tryParse(dayMatch.group(1)!);
      if (days != null) {
        return now.add(Duration(days: days));
      }
    }
    
    final weekMatch = RegExp(r'(\d+)\s*周').firstMatch(lowerStr);
    if (weekMatch != null) {
      final weeks = int.tryParse(weekMatch.group(1)!);
      if (weeks != null) {
        return now.add(Duration(days: weeks * 7));
      }
    }
    
    final monthMatch = RegExp(r'(\d+)\s*个月').firstMatch(lowerStr);
    if (monthMatch != null) {
      final months = int.tryParse(monthMatch.group(1)!);
      if (months != null) {
        return DateTime(now.year, now.month + months, now.day);
      }
    }
    
    return null;
  }

  // 提取Project
  static EntityExtractionResult _extractProject(Map<String, dynamic> data) {
    try {
      final name = data['name'] as String?;
      if (name == null || name.isEmpty) {
        return EntityExtractionResult(error: '项目名称不能为空');
      }

      final description = data['description'] as String?;
      final color = data['color'] as String? ?? '#2196F3';
      final endDateStr = data['endDate'] as String?;
      final statusStr = (data['status'] as String?)?.toLowerCase() ?? 'planning';

      // 解析状态
      ProjectStatus status;
      switch (statusStr) {
        case 'active':
        case '进行中':
          status = ProjectStatus.active;
          break;
        case 'onhold':
        case '暂停':
          status = ProjectStatus.onHold;
          break;
        case 'completed':
        case '完成':
          status = ProjectStatus.completed;
          break;
        case 'cancelled':
        case '取消':
          status = ProjectStatus.cancelled;
          break;
        case 'archived':
        case '归档':
          status = ProjectStatus.archived;
          break;
        default:
          status = ProjectStatus.planning;
      }

      // 解析结束日期
      DateTime? endDate;
      if (endDateStr != null && endDateStr.isNotEmpty) {
        try {
          endDate = DateTime.parse(endDateStr);
        } catch (_) {
          // 日期解析失败，使用null
        }
      }

      final project = Project(
        name: name,
        description: description,
        status: status,
        color: color,
        endDate: endDate,
      );

      return EntityExtractionResult(action: 'create_project', project: project);
    } catch (e) {
      return EntityExtractionResult(error: '创建项目失败: $e');
    }
  }
}

