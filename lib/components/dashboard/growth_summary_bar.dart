import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// XP/等级/犒赏点三合一横条，height: 48pt
class GrowthSummaryBar extends StatelessWidget {
  final int xp;
  final int level;
  final int rewardPoints;

  const GrowthSummaryBar({
    super.key,
    required this.xp,
    required this.level,
    required this.rewardPoints,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing5,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // XP
          _buildItem(
            context: context,
            icon: Icons.bolt,
            iconColor: DesignTokens.secondaryOrange,
            label: 'XP',
            value: '$xp',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          // 等级
          _buildItem(
            context: context,
            icon: Icons.star,
            iconColor: DesignTokens.secondaryPurple,
            label: '等级',
            value: '$level',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          // 犒赏点
          _buildItem(
            context: context,
            icon: Icons.card_giftcard,
            iconColor: DesignTokens.secondaryEmerald,
            label: '犒赏点',
            value: '$rewardPoints',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: DesignTokens.iconSizeMedium,
            color: iconColor,
          ),
          const SizedBox(width: DesignTokens.spacing2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
              Text(
                value,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
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
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
    );
  }
}
