import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 玻璃拟态导航栏
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;
  final bool isDark;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = isDark || Theme.of(context).brightness == Brightness.dark;
    
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? DesignTokens.backgroundDark.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing6,
                vertical: DesignTokens.spacing4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == currentIndex;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected
                                ? DesignTokens.primaryColor
                                : (isDarkMode
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight),
                            size: DesignTokens.iconSizeMedium,
                          ),
                          if (item.label != null) ...[
                            const SizedBox(height: DesignTokens.spacing1),
                            Text(
                              item.label!,
                              style: DesignTokens.textStyle(
                                fontSize: 10,
                                fontWeight: DesignTokens.fontWeightMedium,
                                color: isSelected
                                    ? DesignTokens.primaryColor
                                    : (isDarkMode
                                        ? DesignTokens.textSecondaryDark
                                        : DesignTokens.textSecondaryLight),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 导航栏项
class NavBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String? label;

  const NavBarItem({
    required this.icon,
    required this.selectedIcon,
    this.label,
  });
}

