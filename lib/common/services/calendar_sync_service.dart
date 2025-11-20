import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/logger_service.dart';

/// 日历同步服务
class CalendarSyncService {
  static bool _isEnabled = false;
  static const String _syncEnabledKey = 'calendar_sync_enabled';

  /// 初始化服务
  static Future<void> init() async {
    _isEnabled = DatabaseService.getSetting(_syncEnabledKey, defaultValue: false) as bool;
  }

  /// 是否启用同步
  static bool get isEnabled => _isEnabled;

  /// 启用/禁用同步
  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await DatabaseService.setSetting(_syncEnabledKey, enabled);
    
    if (enabled) {
      await syncAllTodos();
    } else {
      await removeAllEvents();
    }
  }

  /// 同步所有待办事项到系统日历
  static Future<void> syncAllTodos() async {
    if (!_isEnabled) return;

    try {
      final todos = DatabaseService.getAllTodos()
          .where((todo) => todo.dueDate != null && !todo.isDone)
          .toList();

      for (final todo in todos) {
        await _syncTodoToCalendar(todo);
      }

      LoggerService.info('已同步 ${todos.length} 个待办事项到日历', 'CalendarSyncService');
    } catch (e) {
      LoggerService.error('同步待办事项到日历失败', 'CalendarSyncService', e);
    }
  }

  /// 同步单个待办事项到系统日历
  static Future<void> syncTodo(Todo todo) async {
    if (!_isEnabled || todo.dueDate == null || todo.isDone) return;

    try {
      await _syncTodoToCalendar(todo);
      LoggerService.info('已同步待办事项到日历: ${todo.title}', 'CalendarSyncService');
    } catch (e) {
      LoggerService.error('同步待办事项到日历失败', 'CalendarSyncService', e);
    }
  }

  /// 从系统日历移除待办事项
  static Future<void> removeTodo(Todo todo) async {
    if (!_isEnabled) return;

    try {
      // TODO: 实现从系统日历删除事件
      // 需要使用 calendar 插件
      LoggerService.info('已从日历移除待办事项: ${todo.title}', 'CalendarSyncService');
    } catch (e) {
      LoggerService.error('从日历移除待办事项失败', 'CalendarSyncService', e);
    }
  }

  /// 更新系统日历中的待办事项
  static Future<void> updateTodo(Todo todo) async {
    if (!_isEnabled) return;

    try {
      if (todo.dueDate == null || todo.isDone) {
        await removeTodo(todo);
      } else {
        await _syncTodoToCalendar(todo);
      }
    } catch (e) {
      LoggerService.error('更新日历中的待办事项失败', 'CalendarSyncService', e);
    }
  }

  /// 移除所有日历事件
  static Future<void> removeAllEvents() async {
    if (!_isEnabled) return;

    try {
      // TODO: 实现移除所有日历事件
      // 需要使用 calendar 插件
      LoggerService.info('已移除所有日历事件', 'CalendarSyncService');
    } catch (e) {
      LoggerService.error('移除所有日历事件失败', 'CalendarSyncService', e);
    }
  }

  /// 内部方法：同步待办事项到系统日历
  static Future<void> _syncTodoToCalendar(Todo todo) async {
    // TODO: 实现同步到系统日历
    // 需要使用 calendar 插件，例如：
    // - add_2_calendar
    // - calendar
    // 
    // 示例代码：
    // await Calendar.addEvent(
    //   title: todo.title,
    //   description: todo.description ?? '',
    //   startDate: todo.dueDate!,
    //   endDate: todo.dueDate!.add(const Duration(hours: 1)),
    // );
  }
}

