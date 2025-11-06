import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 统一日志服务
class LoggerService {
  static const bool _enableDebugLogs = kDebugMode;
  static const bool _enableInfoLogs = true;
  static const bool _enableWarningLogs = true;
  static const bool _enableErrorLogs = true;
  
  /// 调试日志
  static void debug(String message, [String? tag]) {
    if (!_enableDebugLogs) return;
    _log(LogLevel.debug, message, tag);
  }
  
  /// 信息日志
  static void info(String message, [String? tag]) {
    if (!_enableInfoLogs) return;
    _log(LogLevel.info, message, tag);
  }
  
  /// 警告日志
  static void warning(String message, [String? tag]) {
    if (!_enableWarningLogs) return;
    _log(LogLevel.warning, message, tag);
  }
  
  /// 错误日志
  static void error(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (!_enableErrorLogs) return;
    _log(LogLevel.error, message, tag, error, stackTrace);
  }
  
  static void _log(
    LogLevel level,
    String message,
    String? tag, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final tagStr = tag != null ? '[$tag] ' : '';
    final levelStr = _getLevelString(level);
    final emoji = _getLevelEmoji(level);
    
    final logMessage = '$emoji $levelStr $tagStr$message';
    
    if (level == LogLevel.error && error != null) {
      debugPrint(logMessage);
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    } else {
      debugPrint(logMessage);
    }
    
    // TODO: 在生产环境中，可以将日志写入文件或发送到日志服务
  }
  
  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
  
  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}

