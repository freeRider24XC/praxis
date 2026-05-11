import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 复盘入口按钮，全宽 height: 48pt
class ReviewEntryButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ReviewEntryButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: DesignTokens.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          border: Border.all(
            color: DesignTokens.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: DesignTokens.iconSizeMedium,
              color: DesignTokens.primaryColor,
            ),
            const SizedBox(width: DesignTokens.spacing2),
            Text(
              '每日复盘',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeBodyMedium,
                fontWeight: DesignTokens.fontWeightBold,
                color: DesignTokens.primaryColor,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing2),
            const Icon(
              Icons.chevron_right,
              size: DesignTokens.iconSizeMedium,
              color: DesignTokens.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
