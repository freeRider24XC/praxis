import 'package:flutter/material.dart';
import 'package:praxis/common/models/todo.dart';
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
    final theme = Theme.of(context);
    final isDone = todo.isDone;
    final isOverdue = todo.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: _getPriorityColor(todo.priority),
                ),
                child: Checkbox(
                  value: isDone,
                  onChanged: onToggle != null ? (_) => onToggle!() : null,
                  activeColor: _getPriorityColor(todo.priority),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      todo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? theme.disabledColor : null,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Meta info
                    Wrap(
                      spacing: 8,
                      children: [
                        // Due date
                        if (todo.dueDate != null)
                          _buildChip(
                            icon: Icons.schedule,
                            label: _formatDueDate(todo.dueDate!),
                            color: isOverdue ? Colors.red : null,
                          ),
                        
                        // Priority
                        if (todo.priority != TodoPriority.medium)
                          _buildChip(
                            icon: _getPriorityIcon(todo.priority),
                            label: todo.priority.displayName,
                            color: _getPriorityColor(todo.priority),
                          ),
                        
                        // Tags
                        if (todo.tags != null && todo.tags!.isNotEmpty)
                          ...todo.tags!.take(2).map((tag) => _buildChip(
                            icon: Icons.label_outline,
                            label: tag,
                          )),
                        
                        // Has subtasks
                        if (todo.subTasks != null && todo.subTasks!.isNotEmpty)
                          _buildChip(
                            icon: Icons.checklist,
                            label: '${todo.subTasks!.length}',
                          ),
                        
                        // Has reminder
                        if (todo.reminderTime != null)
                          _buildChip(
                            icon: Icons.notifications_active,
                            label: '',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: theme.disabledColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color ?? Colors.grey,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.urgent:
        return Colors.red;
      case TodoPriority.high:
        return Colors.orange;
      case TodoPriority.medium:
        return Colors.blue;
      case TodoPriority.low:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.urgent:
        return Icons.priority_high;
      case TodoPriority.high:
        return Icons.arrow_upward;
      case TodoPriority.medium:
        return Icons.remove;
      case TodoPriority.low:
        return Icons.arrow_downward;
    }
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
}