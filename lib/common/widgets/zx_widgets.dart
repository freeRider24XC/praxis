// lib/common/widgets/zx_widgets.dart
// ZhiXing 通用卡片组件 - 使用zx缩写

import 'package:flutter/material.dart';
import 'package:zx/common/style/zx_theme.dart';

class ZxCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final List<BoxShadow>? customShadow;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  
  const ZxCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.customShadow,
    this.borderRadius,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ];
    
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: backgroundColor ?? theme.colorScheme.surface,
        elevation: elevation ?? 2,
        shadowColor: Colors.black.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: Container(
            padding: padding ?? EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              boxShadow: customShadow ?? defaultShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// 带图标的卡片
class ZxIconCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  
  const ZxIconCard({
    Key? key,
    required this.title,
    this.subtitle = '',
    required this.icon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ZxCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
        ],
      ),
    );
  }
}

// 统计卡片
class ZxStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? valueColor;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  
  const ZxStatCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.valueColor,
    this.backgroundColor,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ZxCard(
      backgroundColor: backgroundColor,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.primary,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 任务卡片
class ZxTaskCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final String? dueDate;
  final String? priority;
  final List<String>? tags;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  
  const ZxTaskCard({
    Key? key,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority,
    this.tags,
    this.onTap,
    this.onToggleComplete,
    this.backgroundColor,
    this.margin,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(priority, theme);
    
    return ZxCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: onToggleComplete != null
                    ? (_) => onToggleComplete!()
                    : null,
                activeColor: theme.colorScheme.primary,
              ),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (priority != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (dueDate != null && dueDate!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4),
                    Text(
                      dueDate!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              if (tags != null && tags!.isNotEmpty)
                Wrap(
                  spacing: 4,
                  children: tags!.take(3).map((tag) => _buildTag(tag, theme)).toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getPriorityColor(String? priority, ThemeData theme) {
    switch (priority?.toLowerCase()) {
      case 'high':
      case 'urgent':
        return ZxTheme.errorColor;
      case 'medium':
        return ZxTheme.warningColor;
      case 'low':
        return ZxTheme.successColor;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
  
  Widget _buildTag(String tag, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

