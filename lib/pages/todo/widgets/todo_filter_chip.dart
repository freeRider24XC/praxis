import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';

class TodoFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;

  const TodoFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (onDeleted != null) {
      return InputChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 18),
        backgroundColor: Colors.white,
        selectedColor: DesignTokens.primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(
          color: selected ? DesignTokens.primaryColor : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          side: BorderSide(
            color: selected ? DesignTokens.primaryColor : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing3,
          vertical: DesignTokens.spacing2,
        ),
      );
    }

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: DesignTokens.primaryColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        side: BorderSide(
          color: selected ? DesignTokens.primaryColor : Colors.grey.shade300,
          width: selected ? 0 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing3,
        vertical: DesignTokens.spacing2,
      ),
    );
  }
}