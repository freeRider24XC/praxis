import 'dart:convert';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/goal.dart';

class EntityExtractionResult {
  final String? action; // 'create_todo', 'create_goal'
  final Todo? todo;
  final Goal? goal;
  final List<Todo>? todos; // 用于批量创建
  final String? error;

  EntityExtractionResult({
    this.action,
    this.todo,
    this.goal,
    this.todos,
    this.error,
  });

  bool get hasError => error != null;
  bool get hasTodo => todo != null;
  bool get hasGoal => goal != null;
  bool get hasTodos => todos != null && todos!.isNotEmpty;
}

class EntityExtractor {
  // 从AI回复中提取JSON数据
  static EntityExtractionResult extractFromResponse(String response) {
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
        return EntityExtractionResult(error: '未找到JSON数据');
      }

      // 解析JSON
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final action = data['action'] as String?;

      if (action == 'create_todo') {
        return _extractTodo(data);
      } else if (action == 'create_goal') {
        return _extractGoal(data);
      } else {
        return EntityExtractionResult(error: '未知的操作类型: $action');
      }
    } catch (e) {
      // 尝试解析多个待办事项（数组格式）
      try {
        final jsonStart = response.indexOf('[');
        final jsonEnd = response.lastIndexOf(']');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          final jsonStr = response.substring(jsonStart, jsonEnd + 1);
          final data = jsonDecode(jsonStr) as List;
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
        }
      } catch (_) {
        // 忽略数组解析错误
      }
      
      return EntityExtractionResult(error: '解析JSON失败: $e');
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

  // 检查回复中是否包含可提取的实体
  static bool hasExtractableEntity(String response) {
    return response.contains('"action"') && 
           (response.contains('create_todo') || response.contains('create_goal'));
  }
}

