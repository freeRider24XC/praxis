import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 首页主目标卡片，含进度圆环，height: 88pt
class GoalSummaryCard extends StatelessWidget {
  final String title;
  final double progress;
  final String? subtitle;
  final VoidCallback? onTap;

  const GoalSummaryCard({
    super.key,
    required this.title,
    required this.progress,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing5,
          vertical: DesignTokens.spacing4,
        ),
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          boxShadow: DesignTokens.shadowIOS,
          border: Border.all(
            color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // 进度圆环
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 背景圆环
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight,
                    ),
                  ),
                  // 进度圆环
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? DesignTokens.successColor
                          : DesignTokens.primaryColor,
                    ),
                  ),
                  // 圆心文字
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelMedium,
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
            const SizedBox(width: DesignTokens.spacing4),
            // 标题与副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: DesignTokens.spacing1),
                    Text(
                      subtitle!,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeLabelSmall,
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // 箭头
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? DesignTokens.textTertiaryDark
                  : DesignTokens.textTertiaryLight,
              size: DesignTokens.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }
}
