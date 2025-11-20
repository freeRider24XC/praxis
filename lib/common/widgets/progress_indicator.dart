import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 进度指示器组件（支持渐变）
class ProgressIndicator extends StatelessWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final List<Color>? gradientColors;
  final bool showShadow;

  const ProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 10.0,
    this.gradientColors,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark
            ? DesignTokens.surfaceDarkSecondary
            : DesignTokens.surfaceLightSecondary);
    final progressColor = color ?? DesignTokens.primaryColor;
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradientColors != null
                ? LinearGradient(colors: gradientColors!)
                : null,
            color: gradientColors == null ? progressColor : null,
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: progressColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

