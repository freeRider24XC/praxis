import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 当前项目横幅，含状态Badge和进度条，height: 72pt
class ProjectBannerCard extends StatelessWidget {
  final String name;
  final String statusText;
  final Color statusColor;
  final double progress;
  final String? dueDate;
  final VoidCallback? onTap;

  const ProjectBannerCard({
    super.key,
    required this.name,
    required this.statusText,
    required this.statusColor,
    required this.progress,
    this.dueDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing5,
          vertical: DesignTokens.spacing3,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 标题行：项目名 + 状态Badge + 截止日期
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyLarge,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing2),
                // 状态Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing2 + 2,
                    vertical: DesignTokens.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                  child: Text(
                    statusText,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: statusColor,
                    ),
                  ),
                ),
                if (dueDate != null) ...[
                  const SizedBox(width: DesignTokens.spacing2),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                  const SizedBox(width: DesignTokens.spacing1),
                  Text(
                    dueDate!,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: DesignTokens.spacing3),
            // 进度条
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDark
                    ? DesignTokens.borderDark
                    : DesignTokens.borderLight,
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
