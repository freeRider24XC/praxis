import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/constants/task_attributes.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/calendar_sync_service.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/focus/focus_page.dart';
import 'package:praxis/pages/todo/add_todo_page.dart';
import 'package:praxis/pages/todo/todo_detail_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  void initState() {
    super.initState();
    DatabaseService.recalculateProjectProgress(widget.projectId);
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleTaskToggle(Todo todo) async {
    final original = DatabaseService.getTodoById(todo.id);
    if (original == null) return;

    original.isDone = !original.isDone;
    original.completedAt = original.isDone ? DateTime.now() : null;
    original.updatedAt = DateTime.now();
    await DatabaseService.updateTodo(original);
    await CalendarSyncService.updateTodo(original);
    if (original.projectId != null) {
      await DatabaseService.recalculateProjectProgress(original.projectId!);
    }
    if (original.goalId != null) {
      await DatabaseService.recalculateGoalProgress(original.goalId!);
    }
    await _refreshData();
  }

  Future<void> _openTodoDetail(Todo todo) async {
    await Get.to(() => TodoDetailPage(todoId: todo.id));
    await _refreshData();
  }

  Future<void> _openAddTodo(Project project) async {
    await Get.to(() => AddTodoPage(initialProjectId: project.id));
    await _refreshData();
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    }
    return DesignTokens.primaryColor;
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.urgent:
        return DesignTokens.errorColor;
      case TodoPriority.high:
        return DesignTokens.warningColor;
      case TodoPriority.medium:
        return DesignTokens.infoColor;
      case TodoPriority.low:
        return DesignTokens.textSecondaryLight;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';
    if (diff > 0 && diff <= 7) return '$diff天后';
    if (diff < 0 && diff >= -7) return '${-diff}天前';
    return '${dueDate.month}月${dueDate.day}日';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未设定';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  List<Todo> _sortTodos(List<Todo> todos) {
    final sorted = [...todos];
    sorted.sort((a, b) {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate != null && b.dueDate != null) {
        final cmp = a.dueDate!.compareTo(b.dueDate!);
        if (cmp != 0) return cmp;
      }
      return b.priority.value.compareTo(a.priority.value);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final project = DatabaseService.getProjectById(widget.projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('项目不存在')),
        body: const Center(child: Text('项目不存在或已被删除')),
      );
    }

    final goal = DatabaseService.getProjectPrimaryGoal(project);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectColor = _parseColor(project.color);
    final todos = _sortTodos((project.todoIds ?? [])
        .map(DatabaseService.getTodoById)
        .whereType<Todo>()
        .toList());
    final openTodos = todos.where((todo) => !todo.isDone).toList();
    final completedTodos = todos.where((todo) => todo.isDone).toList();
    final leadTodo = openTodos.isNotEmpty ? openTodos.first : null;

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      appBar: AppBar(
        title: const Text('项目推进'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_outlined),
            tooltip: '新增事项',
            onPressed: () => _openAddTodo(project),
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: '管理事项',
            onPressed: () => _showManageTasks(project),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spacing6),
          children: [
            _buildProjectSummaryCard(
              project: project,
              goalTitle: goal?.title,
              projectColor: projectColor,
              todoCount: todos.length,
              openCount: openTodos.length,
              isDark: isDark,
            ),
            const SizedBox(height: DesignTokens.spacing5),
            _buildLeadActionCard(
              project: project,
              leadTodo: leadTodo,
              isDark: isDark,
            ),
            const SizedBox(height: DesignTokens.spacing5),
            _buildExecutionSection(
              project: project,
              title: '这个项目下的事项',
              subtitle: '所有执行动作都应该先挂到项目，再由项目汇入目标。',
              todos: openTodos,
              emptyText: '这个项目还没有待推进事项，先补第一步。',
              isDark: isDark,
              projectColor: projectColor,
            ),
            if (completedTodos.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacing5),
              _buildExecutionSection(
                project: project,
                title: '已完成事项',
                subtitle: '这些动作已经为项目贡献了真实进展。',
                todos: completedTodos.take(6).toList(),
                emptyText: '',
                isDark: isDark,
                projectColor: projectColor,
                showCompletedStyle: true,
              ),
            ],
            if ((project.phases ?? []).isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacing5),
              _buildPhaseSnapshotCard(project, isDark),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(
        project: project,
        leadTodo: leadTodo,
        isDark: isDark,
      ),
    );
  }

  Widget _buildProjectSummaryCard({
    required Project project,
    required String? goalTitle,
    required Color projectColor,
    required int todoCount,
    required int openCount,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: projectColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                ),
                child: Icon(Icons.folder_open, color: projectColor, size: 28),
              ),
              const SizedBox(width: DesignTokens.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeHeadlineSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing2),
                    Text(
                      goalTitle == null
                          ? '这个项目还没有挂到主目标上，先补好归属关系。'
                          : '它是主目标“$goalTitle”的当前推进容器。',
                      style: DesignTokens.textStyle(
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (project.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: DesignTokens.spacing4),
            Text(
              project.description!,
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
              _buildMetaChip(
                icon: Icons.flag_outlined,
                label: goalTitle ?? '未关联主目标',
                color: goalTitle == null
                    ? DesignTokens.warningColor
                    : DesignTokens.primaryColor,
                isDark: isDark,
              ),
              _buildMetaChip(
                icon: Icons.sync_alt_outlined,
                label: project.status.displayName,
                color: projectColor,
                isDark: isDark,
              ),
              if (project.endDate != null)
                _buildMetaChip(
                  icon: Icons.calendar_today_outlined,
                  label: '截止 ${_formatDate(project.endDate)}',
                  color: DesignTokens.secondaryOrange,
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '${(project.progress * 100).round()}%',
                  label: '项目进度',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _buildStatItem(
                  value: '$openCount',
                  label: '待推进事项',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _buildStatItem(
                  value: '$todoCount',
                  label: '总事项数',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadActionCard({
    required Project project,
    required Todo? leadTodo,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前应该推进的一步',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            leadTodo == null
                ? '这个项目暂时没有待办事项，先补一条最小可执行动作。'
                : '先把这一步做掉，项目才会继续往前走。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          if (leadTodo == null)
            OutlinedButton.icon(
              onPressed: () => _openAddTodo(project),
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('为项目添加第一条事项'),
            )
          else
            _buildLeadTodoCard(leadTodo, isDark),
        ],
      ),
    );
  }

  Widget _buildLeadTodoCard(Todo todo, bool isDark) {
    final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDarkSecondary
            : DesignTokens.surfaceLightSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyLarge,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: _getPriorityColor(todo.priority),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Wrap(
            spacing: DesignTokens.spacing2,
            runSpacing: DesignTokens.spacing2,
            children: [
              _buildMetaChip(
                icon: Icons.priority_high,
                label: '优先级 ${todo.priority.displayName}',
                color: _getPriorityColor(todo.priority),
                isDark: isDark,
              ),
              if (attribute != null)
                _buildMetaChip(
                  icon: TaskAttributes.getIcon(attribute),
                  label: TaskAttributes.getDisplayName(attribute),
                  color: TaskAttributes.getColor(attribute, isDark),
                  isDark: isDark,
                ),
              if (todo.dueDate != null)
                _buildMetaChip(
                  icon: Icons.access_time,
                  label: _formatDueDate(todo.dueDate!),
                  color: todo.isOverdue
                      ? DesignTokens.errorColor
                      : DesignTokens.infoColor,
                  isDark: isDark,
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleTaskToggle(todo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('完成这一步'),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.to(() => FocusPage(taskTitle: todo.title)),
                  child: const Text('进入专注'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionSection({
    required Project project,
    required String title,
    required String subtitle,
    required List<Todo> todos,
    required String emptyText,
    required bool isDark,
    required Color projectColor,
    bool showCompletedStyle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
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
                      title,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeTitleLarge,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing1),
                    Text(
                      subtitle,
                      style: DesignTokens.textStyle(
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              TextButton.icon(
                onPressed: showCompletedStyle
                    ? null
                    : () => _openAddTodo(project),
                icon: const Icon(Icons.add, size: 18),
                label: Text(showCompletedStyle ? '${todos.length}条' : '新增'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          if (todos.isEmpty)
            _buildEmptyHint(emptyText, isDark)
          else
            ...todos.map(
              (todo) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
                child: _buildTodoCard(
                  todo: todo,
                  isDark: isDark,
                  accentColor: showCompletedStyle
                      ? DesignTokens.successColor
                      : projectColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodoCard({
    required Todo todo,
    required bool isDark,
    required Color accentColor,
  }) {
    final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);

    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      onTap: () => _openTodoDetail(todo),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.surfaceDarkSecondary
              : DesignTokens.surfaceLightSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _handleTaskToggle(todo),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.isDone
                        ? DesignTokens.successColor
                        : _getPriorityColor(todo.priority),
                    width: 2,
                  ),
                ),
                child: todo.isDone
                    ? const Icon(
                        Icons.check,
                        size: 15,
                        color: DesignTokens.successColor,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ).copyWith(
                      decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (todo.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: DesignTokens.spacing2),
                    Text(
                      todo.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DesignTokens.textStyle(
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: DesignTokens.spacing3),
                  Wrap(
                    spacing: DesignTokens.spacing2,
                    runSpacing: DesignTokens.spacing2,
                    children: [
                      _buildMetaChip(
                        icon: Icons.priority_high,
                        label: '优先级 ${todo.priority.displayName}',
                        color: _getPriorityColor(todo.priority),
                        isDark: isDark,
                      ),
                      if (attribute != null)
                        _buildMetaChip(
                          icon: TaskAttributes.getIcon(attribute),
                          label: TaskAttributes.getDisplayName(attribute),
                          color: TaskAttributes.getColor(attribute, isDark),
                          isDark: isDark,
                        ),
                      if (todo.dueDate != null)
                        _buildMetaChip(
                          icon: Icons.schedule,
                          label: _formatDueDate(todo.dueDate!),
                          color: todo.isOverdue
                              ? DesignTokens.errorColor
                              : DesignTokens.infoColor,
                          isDark: isDark,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.spacing2),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseSnapshotCard(Project project, bool isDark) {
    final phases = project.phases ?? [];
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推进分段',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            '分段只是辅助你组织项目，真正推进仍然靠下面这些事项。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          ...phases.map((phase) {
            final phaseTodos = (phase.todoIds ?? [])
                .map(DatabaseService.getTodoById)
                .whereType<Todo>()
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
              child: Container(
                padding: const EdgeInsets.all(DesignTokens.spacing4),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignTokens.surfaceDarkSecondary
                      : DesignTokens.surfaceLightSecondary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phase.name,
                            style: DesignTokens.textStyle(
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isDark
                                  ? DesignTokens.onSurfaceDark
                                  : DesignTokens.onSurfaceLight,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing1),
                          Text(
                            '包含 $phaseTodos 条事项',
                            style: DesignTokens.textStyle(
                              color: isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(phase.progress * 100).round()}%',
                      style: DesignTokens.textStyle(
                        fontWeight: DesignTokens.fontWeightBold,
                        color: DesignTokens.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar({
    required Project project,
    required Todo? leadTodo,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacing5,
        DesignTokens.spacing4,
        DesignTokens.spacing5,
        DesignTokens.spacing5,
      ),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.backgroundDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openAddTodo(project),
              icon: const Icon(Icons.playlist_add),
              label: const Text('补一条事项'),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Get.to(
                () => FocusPage(taskTitle: leadTodo?.title ?? project.name),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? DesignTokens.surfaceDark : Colors.black,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.play_arrow),
              label: Text(leadTodo == null ? '进入项目专注' : '专注这一步'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDarkSecondary
            : DesignTokens.surfaceLightSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing1),
          Text(
            label,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
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
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(String text, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDarkSecondary
            : DesignTokens.surfaceLightSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Text(
        text,
        style: DesignTokens.textStyle(
          color: isDark
              ? DesignTokens.textSecondaryDark
              : DesignTokens.textSecondaryLight,
        ),
      ),
    );
  }

  void _showManageTasks(Project project) {
    final selectedIds = <String>{...?project.todoIds};
    final allTodos = DatabaseService.getAllTodos();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final maxHeight = MediaQuery.of(context).size.height * 0.7;
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.surfaceDark : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusXLarge),
                  topRight: Radius.circular(DesignTokens.radiusXLarge),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(
                            bottom: DesignTokens.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.borderDark
                                : DesignTokens.borderLight,
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusRound,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '管理这个项目下的事项',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeTitleLarge,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing2),
                      Text(
                        '事项应先归到项目，再由项目汇入目标。',
                        style: DesignTokens.textStyle(
                          color: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      if (allTodos.isEmpty)
                        Text(
                          '暂无事项可选',
                          style: DesignTokens.textStyle(
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: maxHeight),
                          child: ListView(
                            shrinkWrap: true,
                            children: allTodos.map((todo) {
                              final checked = selectedIds.contains(todo.id);
                              return CheckboxListTile(
                                value: checked,
                                title: Text(todo.title),
                                subtitle: todo.dueDate != null
                                    ? Text(
                                        '截止 ${todo.dueDate!.month}/${todo.dueDate!.day}',
                                      )
                                    : null,
                                onChanged: (value) {
                                  setStateModal(() {
                                    if (value == true) {
                                      selectedIds.add(todo.id);
                                    } else {
                                      selectedIds.remove(todo.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: DesignTokens.spacing4),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _openAddTodo(project),
                              child: const Text('新增事项'),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacing3),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await DatabaseService.setProjectTodoLinks(
                                  project.id,
                                  selectedIds.toList(),
                                );
                                Get.back();
                                await _refreshData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignTokens.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('完成'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
