import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 计划卡片组件
class PlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double progress;
  final Color? color;
  final String? category;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PlanCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.progress,
    this.color,
    this.category,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? DesignTokens.secondaryOrange;
    final progressColor = cardColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing5),
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          border: Border.all(
            color: isDark
                ? DesignTokens.borderDark
                : DesignTokens.borderLight,
            width: 0.5,
          ),
          boxShadow: DesignTokens.shadowIOS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：分类标签和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing3,
                      vertical: DesignTokens.spacing1 + 2,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    ),
                    child: Text(
                      category!.toUpperCase(),
                      style: DesignTokens.textStyle(
                        fontSize: 10,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: cardColor,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (trailing != null) trailing!,
              ],
            ),
            
            const SizedBox(height: DesignTokens.spacing3),
            
            // 标题
            Text(
              title,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeTitleLarge,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
            
            if (subtitle != null) ...[
              const SizedBox(height: DesignTokens.spacing1),
              Text(
                subtitle!,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodySmall,
                  fontWeight: DesignTokens.fontWeightMedium,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
            
            const SizedBox(height: DesignTokens.spacing4),
            
            // 进度条
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignTokens.surfaceDarkSecondary
                          : DesignTokens.surfaceLightSecondary,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor,
                              progressColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                          boxShadow: [
                            BoxShadow(
                              color: progressColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing3),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodySmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

