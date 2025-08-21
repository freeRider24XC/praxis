import 'package:flutter/material.dart';

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
      );
    }

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}