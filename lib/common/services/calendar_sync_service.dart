import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/logger_service.dart';

/// Compatibility boundary for a retired feature.
///
/// System calendar synchronization has no platform implementation yet. The
/// setting UI is intentionally hidden until a supported implementation exists.
class CalendarSyncService {
  static const String _syncEnabledKey = 'calendar_sync_enabled';
  static const bool isAvailable = false;

  static bool get isEnabled => false;

  /// Disables an old persisted flag so future callers cannot mistake it for an
  /// active platform integration.
  static Future<void> init() async {
    final wasEnabled =
        DatabaseService.getSetting(_syncEnabledKey, defaultValue: false)
            as bool;
    if (wasEnabled) {
      await DatabaseService.setSetting(_syncEnabledKey, false);
      LoggerService.warning(
        '已关闭未实现的系统日历同步设置',
        'CalendarSyncService',
      );
    }
  }

  /// Retained as no-op compatibility methods for existing Todo call sites.
  static Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      LoggerService.warning(
        '系统日历同步尚未实现，无法启用',
        'CalendarSyncService',
      );
    }
    await DatabaseService.setSetting(_syncEnabledKey, false);
  }

  static Future<void> syncAllTodos() async {}

  static Future<void> syncTodo(Todo todo) async {}

  static Future<void> removeTodo(Todo todo) async {}

  static Future<void> updateTodo(Todo todo) async {}

  static Future<void> removeAllEvents() async {}
}
