import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/calendar_sync_service.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/constants/task_attributes.dart';
import 'package:praxis/pages/focus/focus_page.dart';
import 'package:get/get.dart';

/// 计划详情页
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

  Widget _buildRoadmapEmptyHint(bool isDark) {
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
        '暂无任务，长按任务卡可拖动调整顺序',
        style: DesignTokens.textStyle(
          color: isDark
              ? DesignTokens.textSecondaryDark
              : DesignTokens.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildTimelineTaskList({
    required Project project,
    ProjectPhase? phase,
    required List<Todo> todos,
    required bool isDark,
  }) {
    return ReorderableListView.builder(
      key: ValueKey('route-${phase?.id ?? 'general'}'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      buildDefaultDragHandles: false,
      itemCount: todos.length,
      onReorder: (oldIndex, newIndex) {
        _handleReorder(project, phase, todos, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey('${phase?.id ?? 'general'}-${todo.id}'),
          index: index,
          child: _buildTimelineTaskItem(
            todo: todo,
            isFirstItem: index == 0,
            isLastItem: index == todos.length - 1,
            isDark: isDark,
          ),
        );
      },
    );
  }

  Widget _buildTimelineTaskItem({
    required Todo todo,
    required bool isFirstItem,
    required bool isLastItem,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskTimelineIndicator(isFirstItem, isLastItem, isDark),
          Expanded(
            child: _buildRouteTaskCard(todo, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTimelineIndicator(
    bool isFirstItem,
    bool isLastItem,
    bool isDark,
  ) {
    final lineColor =
        isDark ? DesignTokens.borderDark : DesignTokens.borderLight;
    return SizedBox(
      width: 32,
      child: Column(
        children: [
          if (!isFirstItem)
            Container(
              width: 2,
              height: 12,
              color: lineColor,
            ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: DesignTokens.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          if (!isLastItem)
            Container(
              width: 2,
              height: 12,
              color: lineColor,
            ),
        ],
      ),
    );
  }

  Widget _buildRouteTaskCard(Todo todo, bool isDark) {
    final project = todo.projectId != null
        ? DatabaseService.getProjectById(todo.projectId!)
        : null;
    final goal =
        todo.goalId != null ? DatabaseService.getGoalById(todo.goalId!) : null;
    final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowIOS,
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
                  color: _getPriorityColor(todo.priority),
                  width: 2,
                ),
              ),
              child: todo.isDone
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: _getPriorityColor(todo.priority),
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
                const SizedBox(height: DesignTokens.spacing2),
                Wrap(
                  spacing: DesignTokens.spacing2,
                  runSpacing: DesignTokens.spacing1,
                  children: [
                    if (project != null)
                      _buildAssociationChip(
                        icon: Icons.folder,
                        label: project.name,
                        color: _parseColor(project.color),
                        isDark: isDark,
                      ),
                    if (goal != null)
                      _buildAssociationChip(
                        icon: Icons.flag,
                        label: goal.title,
                        color: DesignTokens.secondaryPurple,
                        isDark: isDark,
                      ),
                    if (attribute != null)
                      _buildAssociationChip(
                        icon: TaskAttributes.getIcon(attribute),
                        label: TaskAttributes.getDisplayName(attribute),
                        color: TaskAttributes.getColor(attribute, isDark),
                        isDark: isDark,
                      ),
                    if (todo.dueDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate(todo.dueDate!),
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeLabelSmall,
                              color: isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spacing2),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!todo.isDone)
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.timer_outlined,
                    color: DesignTokens.primaryColor,
                    size: 22,
                  ),
                  tooltip: '专注',
                  onPressed: () {
                    Get.to(() => FocusPage(taskTitle: todo.title));
                  },
                ),
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: _getPriorityColor(todo.priority),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssociationChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
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

  Future<void> _handleReorder(
    Project project,
    ProjectPhase? phase,
    List<Todo> todos,
    int oldIndex,
    int newIndex,
  ) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final movedTodo = todos.removeAt(oldIndex);
    todos.insert(newIndex, movedTodo);
    final reorderedIds = todos.map((todo) => todo.id).toList();

    final latestProject = DatabaseService.getProjectById(project.id);
    if (latestProject == null) return;

    if (phase != null) {
      final phases = latestProject.phases ?? [];
      final targetIndex = phases.indexWhere((p) => p.id == phase.id);
      if (targetIndex != -1) {
        final updatedPhase = phases[targetIndex];
        updatedPhase.todoIds = reorderedIds;
        phases[targetIndex] = updatedPhase;
        latestProject.phases = phases;
      }
    } else {
      final phases = latestProject.phases ?? [];
      final orderedPhaseIds = <String>[];
      for (final phaseItem in phases) {
        if (phaseItem.todoIds != null) {
          orderedPhaseIds.addAll(phaseItem.todoIds!);
        }
      }
      latestProject.todoIds = [
        ...orderedPhaseIds,
        ...reorderedIds,
      ];
    }

    latestProject.updatedAt = DateTime.now();
    await DatabaseService.updateProject(latestProject);
    await DatabaseService.recalculateProjectProgress(latestProject.id);
    await _refreshData();
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

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {});
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    }
    return DesignTokens.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final project = DatabaseService.getProjectById(widget.projectId);
    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('项目不存在')),
        body: const Center(child: Text('项目不存在')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todos = project.todoIds != null
        ? project.todoIds!
            .map((id) {
              final todo = DatabaseService.getTodoById(id);
              return todo;
            })
            .whereType<Todo>()
            .toList()
        : <Todo>[];

    final phases = project.phases ?? [];
    final phaseTodoIds = <String>{};
    for (final phase in phases) {
      if (phase.todoIds != null) {
        phaseTodoIds.addAll(phase.todoIds!);
      }
    }
    final remainingTodoIds = (project.todoIds ?? [])
        .where((id) => !phaseTodoIds.contains(id))
        .toList();
    final remainingTodos = remainingTodoIds
        .map(DatabaseService.getTodoById)
        .whereType<Todo>()
        .toList();

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 顶部栏
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing6,
                vertical: DesignTokens.spacing4,
              ),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.backgroundDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? DesignTokens.borderDark
                        : DesignTokens.borderLight,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignTokens.surfaceDarkSecondary
                            : DesignTokens.surfaceLightSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? DesignTokens.borderDark
                              : DesignTokens.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '计划详情',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleLarge,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(DesignTokens.spacing8),
                children: [
                  // 项目头部信息
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spacing8),
                    decoration: BoxDecoration(
                      color: isDark ? DesignTokens.surfaceDark : Colors.white,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusXLarge + 8),
                      boxShadow: DesignTokens.shadowIOS,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 图标
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    _parseColor(project.color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusXLarge),
                                border: Border.all(
                                  color: _parseColor(project.color)
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.folder,
                                size: 40,
                                color: _parseColor(project.color),
                              ),
                            ),

                            const SizedBox(width: DesignTokens.spacing5),

                            // 标题和标签
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name,
                                    style: DesignTokens.textStyle(
                                      fontSize:
                                          DesignTokens.fontSizeHeadlineSmall,
                                      fontWeight: DesignTokens.fontWeightBold,
                                      color: isDark
                                          ? DesignTokens.onSurfaceDark
                                          : DesignTokens.onSurfaceLight,
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.spacing2),
                                  Wrap(
                                    spacing: DesignTokens.spacing2,
                                    children: [
                                      if (project.endDate != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: DesignTokens.spacing2,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? DesignTokens
                                                    .surfaceDarkSecondary
                                                : DesignTokens
                                                    .surfaceLightSecondary,
                                            borderRadius: BorderRadius.circular(
                                                DesignTokens.radiusMedium),
                                          ),
                                          child: Text(
                                            '截止: ${project.endDate!.month}月${project.endDate!.day}日',
                                            style: DesignTokens.textStyle(
                                              fontSize: DesignTokens
                                                  .fontSizeLabelSmall,
                                              color: isDark
                                                  ? DesignTokens
                                                      .textSecondaryDark
                                                  : DesignTokens
                                                      .textSecondaryLight,
                                            ),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: DesignTokens.spacing2,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: DesignTokens.secondaryOrange
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                              DesignTokens.radiusMedium),
                                        ),
                                        child: Text(
                                          '中等难度',
                                          style: DesignTokens.textStyle(
                                            fontSize:
                                                DesignTokens.fontSizeLabelSmall,
                                            color: DesignTokens.secondaryOrange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: DesignTokens.spacing6),

                        // 统计信息
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '${project.phases?.length ?? 0}',
                                '阶段',
                                isDark,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '${todos.length}',
                                '任务',
                                isDark,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '30h',
                                '耗时',
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DesignTokens.spacing8),

                  // 执行路线图
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '执行路线图',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showManageTasks(project),
                        icon: const Icon(Icons.link_outlined, size: 16),
                        label: const Text('管理任务'),
                        style: TextButton.styleFrom(
                          foregroundColor: DesignTokens.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacing6),

                  Builder(
                    builder: (context) {
                      final totalSections =
                          phases.length + (remainingTodos.isNotEmpty ? 1 : 0);
                      if (totalSections == 0) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(DesignTokens.spacing5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.surfaceDarkSecondary
                                : DesignTokens.surfaceLightSecondary,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusLarge),
                          ),
                          child: Text(
                            '暂无执行路线，先为项目添加任务吧',
                            style: DesignTokens.textStyle(
                              color: isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight,
                            ),
                          ),
                        );
                      }

                      final widgets = <Widget>[];
                      for (final entry in phases.asMap().entries) {
                        final index = entry.key;
                        final phase = entry.value;
                        final phaseTodos = phase.todoIds != null
                            ? phase.todoIds!
                                .map((id) => DatabaseService.getTodoById(id))
                                .whereType<Todo>()
                                .toList()
                            : <Todo>[];

                        final isActive =
                            phase.status.toString().contains('active');
                        final isCompleted =
                            phase.status.toString().contains('completed');

                        widgets.add(
                          _buildPhaseSection(
                            project: project,
                            phase: phase,
                            phaseName: phase.name,
                            todos: phaseTodos,
                            isActive: isActive,
                            isCompleted: isCompleted,
                            isFirstSection: index == 0,
                            isLastSection: index == totalSections - 1 &&
                                remainingTodos.isEmpty,
                            isDark: isDark,
                          ),
                        );
                      }

                      if (remainingTodos.isNotEmpty) {
                        widgets.add(
                          _buildPhaseSection(
                            project: project,
                            phaseName: '关联任务',
                            todos: remainingTodos,
                            isActive: true,
                            isCompleted: false,
                            isFirstSection: phases.isEmpty,
                            isLastSection: true,
                            isDark: isDark,
                          ),
                        );
                      }

                      return Column(
                        children: widgets,
                      );
                    },
                  ),
                ],
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.backgroundDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? DesignTokens.borderDark
                        : DesignTokens.borderLight,
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => FocusPage(taskTitle: project.name));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? DesignTokens.surfaceDark : Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.spacing4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusXLarge),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, size: 20),
                      const SizedBox(width: DesignTokens.spacing2),
                      Text(
                        '继续执行',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeBodyMedium,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDarkSecondary
            : DesignTokens.surfaceLightSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeHeadlineSmall,
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
              fontSize: 10,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSection({
    required Project project,
    ProjectPhase? phase,
    required String phaseName,
    required List<Todo> todos,
    required bool isActive,
    required bool isCompleted,
    required bool isFirstSection,
    required bool isLastSection,
    required bool isDark,
  }) {
    final lineColor = isActive || isCompleted
        ? DesignTokens.primaryColor.withOpacity(0.35)
        : (isDark ? DesignTokens.borderDark : DesignTokens.borderLight);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLastSection ? 0 : DesignTokens.spacing10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧路线节点
          Column(
            children: [
              if (!isFirstSection)
                Container(
                  width: 3,
                  height: 20,
                  color: lineColor,
                ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: isActive || isCompleted
                      ? LinearGradient(
                          colors: [
                            DesignTokens.primaryColor,
                            DesignTokens.primaryColor.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isActive || isCompleted
                      ? null
                      : (isDark
                          ? DesignTokens.surfaceDarkSecondary
                          : DesignTokens.surfaceLightSecondary),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? DesignTokens.primaryColor
                        : lineColor,
                    width: 4,
                  ),
                ),
              ),
              if (!isLastSection)
                Expanded(
                  child: Container(
                    width: 3,
                    color: lineColor,
                  ),
                ),
            ],
          ),

          const SizedBox(width: DesignTokens.spacing4),

          // 阶段内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      phaseName,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeTitleLarge,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isActive || isCompleted
                            ? (isDark
                                ? DesignTokens.onSurfaceDark
                                : DesignTokens.onSurfaceLight)
                            : (isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? DesignTokens.primaryColor.withOpacity(0.12)
                            : (isCompleted
                                ? DesignTokens.secondaryEmerald
                                    .withOpacity(0.12)
                                : (isDark
                                    ? DesignTokens.surfaceDarkSecondary
                                    : DesignTokens.surfaceLightSecondary)),
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusMedium),
                      ),
                      child: Text(
                        isActive ? '进行中' : (isCompleted ? '已完成' : '未开始'),
                        style: DesignTokens.textStyle(
                          fontSize: 10,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isActive
                              ? DesignTokens.primaryColor
                              : (isCompleted
                                  ? DesignTokens.secondaryEmerald
                                  : (isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing3),
                todos.isEmpty
                    ? _buildRoadmapEmptyHint(isDark)
                    : _buildTimelineTaskList(
                        project: project,
                        phase: phase,
                        todos: todos,
                        isDark: isDark,
                      ),
              ],
            ),
          ),
        ],
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
                              bottom: DesignTokens.spacing4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.borderDark
                                : DesignTokens.borderLight,
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusRound),
                          ),
                        ),
                      ),
                      Text(
                        '管理关联任务',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeTitleLarge,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      if (allTodos.isEmpty)
                        Text(
                          '暂无任务可选',
                          style: DesignTokens.textStyle(
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxHeight,
                          ),
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
                      SizedBox(
                        width: double.infinity,
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
                            padding: const EdgeInsets.symmetric(
                              vertical: DesignTokens.spacing3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusXLarge),
                            ),
                          ),
                          child: const Text('完成'),
                        ),
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
