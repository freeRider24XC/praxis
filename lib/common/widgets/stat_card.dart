import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 统计卡片组件
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final double? progress;
  final IconData? icon;
  final Color? gradientStart;
  final Color? gradientEnd;
  final List<StatBadge>? badges;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.progress,
    this.icon,
    this.gradientStart,
    this.gradientEnd,
    this.badges,
  });

  @override
  Widget build(BuildContext context) {
    final startColor = gradientStart ?? DesignTokens.primaryColor;
    final endColor = gradientEnd ?? DesignTokens.primaryDark;
    
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowFloat,
      ),
      child: Stack(
        children: [
          // 装饰背景
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DesignTokens.secondaryPurple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // 内容
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.toUpperCase(),
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeLabelSmall,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacing1),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              value,
                              style: DesignTokens.textStyle(
                                fontSize: 48,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: Colors.white,
                              ),
                            ),
                            if (unit != null) ...[
                              const SizedBox(width: DesignTokens.spacing1),
                              Text(
                                unit!,
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeTitleLarge,
                                  fontWeight: DesignTokens.fontWeightMedium,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (icon != null)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: DesignTokens.iconSizeLarge,
                      ),
                    ),
                ],
              ),
              
              if (progress != null) ...[
                const SizedBox(height: DesignTokens.spacing4),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress!.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
              if (badges != null && badges!.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacing4),
                Wrap(
                  spacing: DesignTokens.spacing2,
                  runSpacing: DesignTokens.spacing2,
                  children: badges!.map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing3,
                        vertical: DesignTokens.spacing1 + 2,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badge.icon != null) ...[
                            Icon(
                              badge.icon,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: DesignTokens.spacing1),
                          ],
                          Text(
                            badge.text,
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeLabelSmall,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 统计徽章
class StatBadge {
  final String text;
  final IconData? icon;

  const StatBadge({
    required this.text,
    this.icon,
  });
}

