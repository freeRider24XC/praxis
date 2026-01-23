import 'package:flutter/material.dart';
import 'package:zx/common/style/design_tokens.dart';
import 'package:zx/common/widgets/praxis_button.dart';

/// 统一的空状态组件
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.showAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: DesignTokens.iconSizeXLarge * 2,
              color: isDark ? DesignTokens.onSurfaceDark.withOpacity(0.3) : DesignTokens.onSurfaceLight.withOpacity(0.3),
            ),
            const SizedBox(height: DesignTokens.spacing6),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: DesignTokens.fontWeightMedium,
                color: isDark ? DesignTokens.onSurfaceDark.withOpacity(0.7) : DesignTokens.onSurfaceLight.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: DesignTokens.spacing3),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? DesignTokens.onSurfaceDark.withOpacity(0.5) : DesignTokens.onSurfaceLight.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showAction && actionLabel != null && onAction != null) ...[
              const SizedBox(height: DesignTokens.spacing6),
              PraxisButton(
                text: actionLabel!,
                onPressed: onAction,
                type: PraxisButtonType.primary,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
