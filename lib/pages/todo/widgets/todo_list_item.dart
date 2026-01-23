import 'package:flutter/material.dart';
import 'package:zx/common/models/todo.dart';
import 'package:zx/common/widgets/zx_widgets.dart';
import 'package:zx/common/style/design_tokens.dart';
import 'package:intl/intl.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TodoListItem({
    super.key,
    required this.todo,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = todo.isDone;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: DesignTokens.successColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: DesignTokens.errorColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          onDelete!();
        } else if (direction == DismissDirection.startToEnd && onToggle != null) {
          onToggle!();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('删除待办事项'),
              content: Text('确定要删除"${todo.title}"吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('删除'),
                ),
              ],
            ),
          ) ?? false;
        }
        return true;
      },
      child: ZxTaskCard(
        title: todo.title,
        description: todo.description,
        isCompleted: isDone,
        dueDate: todo.dueDate != null ? _formatDueDate(todo.dueDate!) : null,
        priority: _getPriorityString(todo.priority),
        tags: todo.tags,
        onTap: onTap,
        onToggleComplete: onToggle,
        margin: const EdgeInsets.only(bottom: DesignTokens.spacing2),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == tomorrow) {
      return '明天';
    } else if (dateOnly.isBefore(today)) {
      final days = today.difference(dateOnly).inDays;
      return '逾期$days天';
    } else if (dateOnly.difference(today).inDays < 7) {
      return DateFormat('EEEE', 'zh_CN').format(date);
    } else {
      return DateFormat('MM月dd日').format(date);
    }
  }

  String _getPriorityString(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.urgent:
        return 'urgent';
      case TodoPriority.high:
        return 'high';
      case TodoPriority.medium:
        return 'medium';
      case TodoPriority.low:
        return 'low';
    }
  }
}