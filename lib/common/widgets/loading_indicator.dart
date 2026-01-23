import 'package:flutter/material.dart';
import 'package:zx/common/style/design_tokens.dart';

/// 统一的加载指示器组件
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? DesignTokens.iconSizeXLarge,
            height: size ?? DesignTokens.iconSizeXLarge,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? DesignTokens.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: DesignTokens.spacing4),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 骨架屏加载指示器
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(DesignTokens.radiusMedium),
      ),
    );
  }
}

