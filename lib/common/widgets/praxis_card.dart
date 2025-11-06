import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 统一的卡片组件
class PraxisCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showShadow;

  const PraxisCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Widget card = Container(
      decoration: BoxDecoration(
        color: color ?? (isDark ? DesignTokens.surfaceDark : DesignTokens.surfaceLight),
        borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: showShadow ? DesignTokens.shadowMedium : null,
      ),
      padding: padding ?? const EdgeInsets.all(DesignTokens.spacing4),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusLarge),
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(
        padding: margin!,
        child: card,
      );
    }

    return card;
  }
}

