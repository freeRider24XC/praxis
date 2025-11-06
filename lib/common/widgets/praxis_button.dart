import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 统一的按钮组件
class PraxisButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final PraxisButtonType type;
  final PraxisButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const PraxisButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = PraxisButtonType.primary,
    this.size = PraxisButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final height = _getHeight();
    final style = _getTextStyle(context);
    final backgroundColor = _getBackgroundColor(context, isDark);
    final foregroundColor = _getForegroundColor(context, isDark);
    final padding = _getPadding();

    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        minimumSize: Size(isFullWidth ? double.infinity : 0, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        elevation: type == PraxisButtonType.primary ? 2 : 0,
      ),
      child: _buildChild(style),
    );

    if (type == PraxisButtonType.outline) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: padding,
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          side: BorderSide(color: foregroundColor),
        ),
        child: _buildChild(style),
      );
    } else if (type == PraxisButtonType.text) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: padding,
          minimumSize: Size(isFullWidth ? double.infinity : 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
        ),
        child: _buildChild(style),
      );
    }

    return AnimatedContainer(
      duration: DesignTokens.durationFast,
      child: button,
    );
  }

  Widget _buildChild(TextStyle style) {
    if (isLoading) {
      return SizedBox(
        height: style.fontSize,
        width: style.fontSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(style.color ?? Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: style.fontSize),
          const SizedBox(width: DesignTokens.spacing2),
          Text(text, style: style),
        ],
      );
    }

    return Text(text, style: style);
  }

  double _getHeight() {
    switch (size) {
      case PraxisButtonSize.small:
        return DesignTokens.buttonHeightSmall;
      case PraxisButtonSize.medium:
        return DesignTokens.buttonHeight;
      case PraxisButtonSize.large:
        return DesignTokens.buttonHeightLarge;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case PraxisButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing3,
          vertical: DesignTokens.spacing2,
        );
      case PraxisButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing4,
          vertical: DesignTokens.spacing3,
        );
      case PraxisButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing6,
          vertical: DesignTokens.spacing4,
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    switch (size) {
      case PraxisButtonSize.small:
        return theme.textTheme.labelLarge?.copyWith(
          fontWeight: DesignTokens.fontWeightMedium,
        ) ?? const TextStyle();
      case PraxisButtonSize.medium:
        return theme.textTheme.titleSmall?.copyWith(
          fontWeight: DesignTokens.fontWeightMedium,
        ) ?? const TextStyle();
      case PraxisButtonSize.large:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: DesignTokens.fontWeightSemiBold,
        ) ?? const TextStyle();
    }
  }

  Color _getBackgroundColor(BuildContext context, bool isDark) {
    if (type == PraxisButtonType.primary) {
      return DesignTokens.primaryColor;
    } else if (type == PraxisButtonType.secondary) {
      return isDark ? DesignTokens.surfaceDark : DesignTokens.surfaceLight;
    }
    return Colors.transparent;
  }

  Color _getForegroundColor(BuildContext context, bool isDark) {
    if (type == PraxisButtonType.primary) {
      return Colors.white;
    } else if (type == PraxisButtonType.secondary) {
      return isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight;
    }
    return DesignTokens.primaryColor;
  }
}

enum PraxisButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum PraxisButtonSize {
  small,
  medium,
  large,
}

