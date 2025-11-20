import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 搜索栏组件
class SearchBar extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final bool enabled;

  const SearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onTap,
    this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing4,
          vertical: DesignTokens.spacing3 + 2,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.surfaceDarkSecondary
              : DesignTokens.surfaceLightSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          border: Border.all(
            color: isDark
                ? DesignTokens.borderDark
                : DesignTokens.borderLight,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: DesignTokens.iconSizeSmall + 2,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
            const SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: enabled && controller != null
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodySmall,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText ?? '搜索计划或任务...',
                        hintStyle: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeBodySmall,
                          color: isDark
                              ? DesignTokens.textTertiaryDark
                              : DesignTokens.textTertiaryLight,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      hintText ?? '搜索计划或任务...',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodySmall,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                        color: isDark
                            ? DesignTokens.textTertiaryDark
                            : DesignTokens.textTertiaryLight,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

