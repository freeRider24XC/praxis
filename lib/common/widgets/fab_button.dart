import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 自定义FAB按钮（居中悬浮，带旋转动画）
class FabButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FabButton({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<FabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationNormal,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? DesignTokens.surfaceDark : Colors.black);
    final fgColor = widget.foregroundColor ?? Colors.white;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.05);
          final rotation = _controller.value * 90;
          
          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation * 3.14159 / 180,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? DesignTokens.backgroundDark
                        : DesignTokens.backgroundLight,
                    width: 6,
                  ),
                  boxShadow: DesignTokens.shadowFloat,
                ),
                child: Icon(
                  widget.icon,
                  color: fgColor,
                  size: DesignTokens.iconSizeLarge,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

