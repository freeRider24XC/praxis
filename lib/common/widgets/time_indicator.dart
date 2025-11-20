import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 时间指示器组件
class TimeIndicator extends StatelessWidget {
  final DateTime? date;
  final String? customText;

  const TimeIndicator({
    super.key,
    this.date,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    if (customText != null) {
      return _buildText(customText!);
    }
    
    if (date == null) {
      return const SizedBox.shrink();
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date!.year, date!.month, date!.day);
    
    String text;
    if (dateOnly == today) {
      text = '今天';
    } else if (dateOnly == tomorrow) {
      text = '明天';
    } else {
      final diff = dateOnly.difference(today).inDays;
      if (diff > 0) {
        text = '还有 $diff 天';
      } else if (diff < 0) {
        text = '已过期 ${-diff} 天';
      } else {
        final month = date!.month;
        final day = date!.day;
        text = '$month月$day日';
      }
    }
    
    return _buildText(text);
  }
  
  Widget _buildText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(
          color: DesignTokens.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: DesignTokens.textStyle(
          fontSize: DesignTokens.fontSizeLabelSmall,
          fontWeight: DesignTokens.fontWeightBold,
          color: DesignTokens.primaryColor,
        ),
      ),
    );
  }
}

