import 'package:flutter/material.dart';

/// 设计令牌 - 统一的设计系统定义
class DesignTokens {
  DesignTokens._();

  // ==================== 颜色系统 ====================
  
  /// 主色调
  static const Color primaryColor = Color(0xFF2196F3); // 蓝色
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  /// 辅助色
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFFFF9800);
  
  /// 语义色
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  /// 中性色（亮色模式）
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color onSurfaceLight = Color(0xFF212121);
  static const Color onBackgroundLight = Color(0xFF212121);
  
  /// 中性色（暗色模式）
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  
  /// 优先级颜色
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFFF5722);
  static const Color priorityUrgent = Color(0xFFF44336);
  
  /// 状态颜色
  static const Color statusActive = Color(0xFF2196F3);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusPaused = Color(0xFFFF9800);
  static const Color statusCancelled = Color(0xFFF44336);
  
  // ==================== 字体系统 ====================
  
  /// 字体系列
  static const String fontFamily = 'Roboto';
  
  /// 字号
  static const double fontSizeDisplayLarge = 57.0;
  static const double fontSizeDisplayMedium = 45.0;
  static const double fontSizeDisplaySmall = 36.0;
  static const double fontSizeHeadlineLarge = 32.0;
  static const double fontSizeHeadlineMedium = 28.0;
  static const double fontSizeHeadlineSmall = 24.0;
  static const double fontSizeTitleLarge = 22.0;
  static const double fontSizeTitleMedium = 16.0;
  static const double fontSizeTitleSmall = 14.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeBodyMedium = 14.0;
  static const double fontSizeBodySmall = 12.0;
  static const double fontSizeLabelLarge = 14.0;
  static const double fontSizeLabelMedium = 12.0;
  static const double fontSizeLabelSmall = 11.0;
  
  /// 字重
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  /// 行高
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  
  // ==================== 间距系统（4px基准网格）====================
  
  static const double spacing0 = 0.0;
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;
  static const double spacing16 = 64.0;
  
  // ==================== 圆角 ====================
  
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 999.0;
  
  // ==================== 阴影 ====================
  
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // ==================== 动画时长 ====================
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // ==================== 动画曲线 ====================
  
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveBounce = Curves.bounceOut;
  
  // ==================== 组件尺寸 ====================
  
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  
  // ==================== 工具方法 ====================
  
  /// 根据亮度获取文本颜色
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? onBackgroundLight : onBackgroundDark;
  }
  
  /// 获取优先级颜色
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return priorityLow;
      case 1:
        return priorityMedium;
      case 2:
        return priorityHigh;
      case 3:
        return priorityUrgent;
      default:
        return priorityMedium;
    }
  }
}

