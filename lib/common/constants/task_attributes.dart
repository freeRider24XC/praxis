import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 任务属性标签定义
class TaskAttributes {
  // 属性标签值
  static const String life = 'life';
  static const String work = 'work';
  static const String study = 'study';
  static const String fitness = 'fitness';
  static const String travel = 'travel';
  static const String health = 'health';
  static const String finance = 'finance';
  static const String hobby = 'hobby';
  static const String family = 'family';
  static const String social = 'social';

  // 所有属性标签列表
  static const List<String> allAttributes = [
    life,
    work,
    study,
    fitness,
    travel,
    health,
    finance,
    hobby,
    family,
    social,
  ];

  // 获取属性标签的显示名称
  static String getDisplayName(String attribute) {
    switch (attribute) {
      case life:
        return '生活';
      case work:
        return '工作';
      case study:
        return '学习';
      case fitness:
        return '运动';
      case travel:
        return '旅行';
      case health:
        return '健康';
      case finance:
        return '财务';
      case hobby:
        return '爱好';
      case family:
        return '家庭';
      case social:
        return '社交';
      default:
        return attribute;
    }
  }

  // 获取属性标签的颜色
  static Color getColor(String attribute, bool isDark) {
    switch (attribute) {
      case life:
        return isDark
            ? DesignTokens.secondaryEmerald.withOpacity(0.8)
            : DesignTokens.secondaryEmerald;
      case work:
        return isDark
            ? DesignTokens.primaryColor.withOpacity(0.8)
            : DesignTokens.primaryColor;
      case study:
        return isDark
            ? DesignTokens.secondaryPurple.withOpacity(0.8)
            : DesignTokens.secondaryPurple;
      case fitness:
        return isDark
            ? DesignTokens.secondaryOrange.withOpacity(0.8)
            : DesignTokens.secondaryOrange;
      case travel:
        return isDark
            ? DesignTokens.infoColor.withOpacity(0.8)
            : DesignTokens.infoColor;
      case health:
        return isDark
            ? DesignTokens.successColor.withOpacity(0.8)
            : DesignTokens.successColor;
      case finance:
        return isDark
            ? DesignTokens.warningColor.withOpacity(0.8)
            : DesignTokens.warningColor;
      case hobby:
        return isDark
            ? DesignTokens.secondaryPurple.withOpacity(0.8)
            : DesignTokens.secondaryPurple;
      case family:
        return isDark
            ? DesignTokens.secondaryEmerald.withOpacity(0.8)
            : DesignTokens.secondaryEmerald;
      case social:
        return isDark
            ? DesignTokens.primaryColor.withOpacity(0.8)
            : DesignTokens.primaryColor;
      default:
        return isDark
            ? DesignTokens.textSecondaryDark
            : DesignTokens.textSecondaryLight;
    }
  }

  // 获取属性标签的图标
  static IconData getIcon(String attribute) {
    switch (attribute) {
      case life:
        return Icons.home;
      case work:
        return Icons.work;
      case study:
        return Icons.school;
      case fitness:
        return Icons.fitness_center;
      case travel:
        return Icons.flight;
      case health:
        return Icons.health_and_safety;
      case finance:
        return Icons.account_balance_wallet;
      case hobby:
        return Icons.palette;
      case family:
        return Icons.family_restroom;
      case social:
        return Icons.people;
      default:
        return Icons.label;
    }
  }

  // 检查是否为有效的属性标签
  static bool isValid(String attribute) {
    return allAttributes.contains(attribute);
  }

  // 从tags中提取属性标签（返回第一个匹配的属性标签）
  static String? extractAttributeFromTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) return null;
    for (final tag in tags) {
      if (isValid(tag)) {
        return tag;
      }
    }
    return null;
  }
}

