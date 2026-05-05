import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/goal/goal_detail_page.dart';

class TodoDetailPage extends StatefulWidget {
  final String todoId;

  const TodoDetailPage({super.key, required this.todoId});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  Todo? _todo;
  Project? _project;
  Goal? _goal;

  @override
  void initState() {
    super.initState();
    _loadTodo();
  }

  void _loadTodo() {
    final todo = DatabaseService.getTodoById(widget.todoId);
    setState(() {
      _todo = todo;
      _project = (todo?.projectId != null)
          ? DatabaseService.getProjectById(todo!.projectId!)
          : null;
      _goal = (todo?.goalId != null)
          ? DatabaseService.getGoalById(todo!.goalId!)
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final todo = _todo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('任务详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: todo == null
                ? null
                : () async {
                    final result =
                        await Get.toNamed('/todo/add', arguments: todo);
                    if (result == true) {
                      _loadTodo();
                    }
                  },
          ),
        ],
      ),
      body: todo == null
          ? Center(
              child: Text(
                '任务不存在或已被删除',
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(todo, isDark),
                  const SizedBox(height: DesignTokens.spacing6),
                  _buildAssociationSection(isDark),
                  const SizedBox(height: DesignTokens.spacing6),
                  if (todo.tags?.isNotEmpty ?? false)
                    _buildTagsSection(todo.tags!, isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(Todo todo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: todo.isDone,
                onChanged: (value) async {
                  final wasDone = todo.isDone;
                  todo.isDone = value ?? false;
                  todo.completedAt =
                      todo.isDone ? DateTime.now() : null;
                  await DatabaseService.updateTodo(todo);
                  if (!wasDone && todo.isDone) {
                    await XpService.awardTodoCompleted(todo);
                  }
                  _loadTodo();
                },
              ),
              Expanded(
                child: Text(
                  todo.title,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeHeadlineSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
              ),
            ],
          ),
          if (todo.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: DesignTokens.spacing3),
            Text(
              todo.description!,
              style: DesignTokens.textStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.spacing4),
          Wrap(
            spacing: DesignTokens.spacing2,
            runSpacing: DesignTokens.spacing2,
            children: [
              _buildChip(
                label: todo.priority.displayName,
                color: DesignTokens.primaryColor,
                isDark: isDark,
              ),
              if (todo.dueDate != null)
                _buildChip(
                  label: '截止 ${todo.dueDate!.month}/${todo.dueDate!.day}',
                  color: DesignTokens.secondaryPurple,
                  isDark: isDark,
                ),
              _buildChip(
                label: todo.isDone ? '已完成' : '未完成',
                color: todo.isDone
                    ? DesignTokens.secondaryEmerald
                    : DesignTokens.warningColor,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '关联信息',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          _buildAssociationTile(
            title: '所属项目',
            value: _project?.name ?? '未关联',
            isDark: isDark,
            onTap: _project == null
                ? null
                : () async {
                    await Get.to(
                      () => ProjectDetailPage(projectId: _project!.id),
                    );
                    _loadTodo();
                  },
          ),
          const SizedBox(height: DesignTokens.spacing3),
          _buildAssociationTile(
            title: '关联目标',
            value: _goal?.title ?? '未关联',
            isDark: isDark,
            onTap: _goal == null
                ? null
                : () async {
                    await Get.to(
                      () => GoalDetailPage(goalId: _goal!.id),
                    );
                    _loadTodo();
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationTile({
    required String title,
    required String value,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: DesignTokens.textStyle(
          color: isDark
              ? DesignTokens.textSecondaryDark
              : DesignTokens.textSecondaryLight,
        ),
      ),
      subtitle: Text(
        value,
        style: DesignTokens.textStyle(
          fontSize: DesignTokens.fontSizeBodyLarge,
          fontWeight: DesignTokens.fontWeightBold,
          color: enabled
              ? (isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight)
              : (isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight),
        ),
      ),
      trailing: enabled ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildTagsSection(List<String> tags, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '标签',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Wrap(
            spacing: DesignTokens.spacing2,
            runSpacing: DesignTokens.spacing2,
            children: tags
                .map(
                  (tag) => _buildChip(
                    label: tag,
                    color: DesignTokens.secondaryEmerald,
                    isDark: isDark,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
      ),
      child: Text(
        label,
        style: DesignTokens.textStyle(
          fontSize: DesignTokens.fontSizeLabelSmall,
          fontWeight: DesignTokens.fontWeightBold,
          color: color,
        ),
      ),
    );
  }
}
