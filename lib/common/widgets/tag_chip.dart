import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 标签芯片组件
class TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TagChipStyle style;
  final VoidCallback? onTap;
  final bool isSelected;

  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.style = TagChipStyle.primary,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    if (isSelected) {
      switch (style) {
        case TagChipStyle.primary:
          backgroundColor = DesignTokens.primaryColor.withOpacity(0.1);
          textColor = DesignTokens.primaryColor;
          borderColor = DesignTokens.primaryColor.withOpacity(0.3);
          break;
        case TagChipStyle.secondary:
          backgroundColor = DesignTokens.secondaryPurple.withOpacity(0.1);
          textColor = DesignTokens.secondaryPurple;
          borderColor = DesignTokens.secondaryPurple.withOpacity(0.3);
          break;
        case TagChipStyle.success:
          backgroundColor = DesignTokens.secondaryEmerald.withOpacity(0.1);
          textColor = DesignTokens.secondaryEmerald;
          borderColor = DesignTokens.secondaryEmerald.withOpacity(0.3);
          break;
        case TagChipStyle.warning:
          backgroundColor = DesignTokens.secondaryOrange.withOpacity(0.1);
          textColor = DesignTokens.secondaryOrange;
          borderColor = DesignTokens.secondaryOrange.withOpacity(0.3);
          break;
        case TagChipStyle.neutral:
          backgroundColor = isDark
              ? DesignTokens.surfaceDarkSecondary
              : DesignTokens.surfaceLightSecondary;
          textColor = isDark
              ? DesignTokens.onSurfaceDark
              : DesignTokens.onSurfaceLight;
          borderColor = isDark
              ? DesignTokens.borderDark
              : DesignTokens.borderLight;
          break;
      }
    } else {
      backgroundColor = isDark
          ? DesignTokens.surfaceDarkSecondary
          : DesignTokens.surfaceLightSecondary;
      textColor = isDark
          ? DesignTokens.textSecondaryDark
          : DesignTokens.textSecondaryLight;
      borderColor = isDark
          ? DesignTokens.borderDark
          : DesignTokens.borderLight;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing4,
          vertical: DesignTokens.spacing2 + 2,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: textColor,
              ),
              const SizedBox(width: DesignTokens.spacing1),
            ],
            Text(
              label,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeBodySmall,
                fontWeight: DesignTokens.fontWeightBold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 标签芯片样式
enum TagChipStyle {
  primary,
  secondary,
  success,
  warning,
  neutral,
}

