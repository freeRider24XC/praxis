import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 统一错误处理服务
class ErrorService {
  static void handleError(
    dynamic error, {
    String? context,
    bool showSnackbar = true,
    VoidCallback? onError,
  }) {
    // 记录错误
    _logError(error, context);
    
    // 显示用户友好的错误提示
    if (showSnackbar) {
      _showErrorSnackbar(error);
    }
    
    // 执行自定义错误处理
    onError?.call();
  }
  
  static void _logError(dynamic error, String? context) {
    final message = error.toString();
    final contextStr = context != null ? '[$context] ' : '';
    debugPrint('❌ Error $contextStr: $message');
    
    // TODO: 可以在这里添加错误上报到日志服务
  }
  
  static void _showErrorSnackbar(dynamic error) {
    String message;
    
    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      message = error;
    } else {
      message = '发生未知错误，请稍后重试';
    }
    
    // 限制消息长度
    if (message.length > 100) {
      message = '${message.substring(0, 100)}...';
    }
    
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
  
  /// 显示成功提示
  static void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
  
  /// 显示警告提示
  static void showWarning(String message) {
    Get.snackbar(
      '警告',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
  
  /// 显示信息提示
  static void showInfo(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}

