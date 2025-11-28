import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/constants/task_attributes.dart';
import 'package:praxis/pages/goal/goal_detail_page.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/focus/focus_page.dart';

/// 管理页面 - 目标、项目、任务管理
class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Goal> _goals = [];
  List<Project> _projects = [];
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final goals = DatabaseService.getAllGoals();
    final projects = DatabaseService.getAllProjects();
    final todos = DatabaseService.getAllTodos();

    for (final project in projects) {
      await DatabaseService.recalculateProjectProgress(project.id);
    }

    if (!mounted) return;
    setState(() {
      _goals = goals;
      _projects = DatabaseService.getAllProjects();
      _todos = todos;
    });
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
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '明天';
    } else if (difference == -1) {
      return '昨天';
    } else if (difference > 0 && difference <= 7) {
      return '$difference天后';
    } else if (difference < 0 && difference >= -7) {
      return '${-difference}天前';
    } else {
      return '${dueDate.month}月${dueDate.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing6,
                vertical: DesignTokens.spacing4,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? DesignTokens.backgroundDark
                    : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? DesignTokens.borderDark
                        : DesignTokens.borderLight,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '管理',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeHeadlineSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: DesignTokens.primaryColor,
                        ),
                        onPressed: () {
                          _showCreateMenu(context, isDark);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  // Tab切换
                  TabBar(
                    controller: _tabController,
                    indicatorColor: DesignTokens.primaryColor,
                    labelColor: DesignTokens.primaryColor,
                    unselectedLabelColor: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                    tabs: const [
                      Tab(text: '目标'),
                      Tab(text: '项目'),
                      Tab(text: '任务'),
                    ],
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGoalsTab(isDark),
                  _buildProjectsTab(isDark),
                  _buildTodosTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      children: [
        if (_goals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    '暂无目标',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._goals.map((goal) {
            return _buildGoalCard(goal, isDark);
          }),
      ],
    );
  }

  Widget _buildProjectsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      children: [
        if (_projects.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    '暂无项目',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._projects.map((project) {
            return _buildProjectCard(project, isDark);
          }),
      ],
    );
  }

  Widget _buildTodosTab(bool isDark) {
    // 按未完成优先排序
    final sortedTodos = List<Todo>.from(_todos)
      ..sort((a, b) {
        if (a.isDone != b.isDone) {
          return a.isDone ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      children: [
        if (_todos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing16),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    '暂无任务',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...sortedTodos.map((todo) {
            return _buildTodoCard(todo, isDark);
          }),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal, bool isDark) {
    final computedProgress = _calculateGoalProgress(goal);
    final progressPercent = (computedProgress * 100).clamp(0, 100).toInt();
    final progressSource = _getGoalProgressSource(goal);

    return InkWell(
      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      onTap: () async {
        await Get.to(() => GoalDetailPage(goalId: goal.id));
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spacing4),
        padding: const EdgeInsets.all(DesignTokens.spacing5),
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          border: Border.all(
            color: isDark
                ? DesignTokens.borderDark
                : DesignTokens.borderLight,
            width: 0.5,
          ),
          boxShadow: DesignTokens.shadowIOS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleLarge,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('编辑'),
                      onTap: () async {
                        await Get.toNamed('/goal/add', arguments: goal);
                        _loadData();
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('删除'),
                      onTap: () {
                        DatabaseService.deleteGoal(goal);
                        _loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacing2),
              Text(
                goal.description!,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodySmall,
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
                  child: LinearProgressIndicator(
                    value: computedProgress,
                    backgroundColor: isDark
                        ? DesignTokens.surfaceDarkSecondary
                        : DesignTokens.surfaceLightSecondary,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      DesignTokens.secondaryPurple,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$progressPercent%',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeLabelSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: DesignTokens.secondaryPurple,
                      ),
                    ),
                    Text(
                      progressSource,
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
    );
  }

  Widget _buildProjectCard(Project project, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing4),
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark
              ? DesignTokens.borderDark
              : DesignTokens.borderLight,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: InkWell(
        onTap: () async {
          await Get.to(() => ProjectDetailPage(projectId: project.id));
          _loadData();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleLarge,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('编辑'),
                      onTap: () async {
                        await Get.toNamed('/project/add', arguments: project);
                        _loadData();
                      },
                    ),
                    PopupMenuItem(
                      child: const Text('删除'),
                      onTap: () {
                        DatabaseService.deleteProject(project);
                        _loadData();
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (project.description != null && project.description!.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacing2),
              Text(
                project.description!,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodySmall,
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
                  child: LinearProgressIndicator(
                    value: project.progress,
                    backgroundColor: isDark
                        ? DesignTokens.surfaceDarkSecondary
                        : DesignTokens.surfaceLightSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _parseColor(project.color),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing4),
                Text(
                  '${(project.progress * 100).toInt()}%',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: _parseColor(project.color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(Todo todo, bool isDark) {
    final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);
    
    Project? project;
    if (todo.projectId != null) {
      try {
        project = _projects.firstWhere((p) => p.id == todo.projectId);
      } catch (_) {
        project = null;
      }
    }
    
    Goal? goal;
    if (todo.goalId != null) {
      try {
        goal = _goals.firstWhere((g) => g.id == todo.goalId);
      } catch (_) {
        goal = null;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark
              ? DesignTokens.borderDark
              : DesignTokens.borderLight,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Row(
        children: [
          // 复选框
          GestureDetector(
            onTap: () async {
              final originalTodo = DatabaseService.getTodoById(todo.id);
              if (originalTodo != null) {
                originalTodo.isDone = !originalTodo.isDone;
                originalTodo.completedAt = originalTodo.isDone ? DateTime.now() : null;
                originalTodo.updatedAt = DateTime.now();
                await DatabaseService.updateTodo(originalTodo);
                _loadData();
              }
            },
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
          // 任务信息
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
                    decoration: todo.isDone
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing2),
                Wrap(
                  spacing: DesignTokens.spacing2,
                  runSpacing: DesignTokens.spacing1,
                  children: [
                    if (project != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _parseColor(project.color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder,
                              size: 10,
                              color: _parseColor(project.color),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              project.name,
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeLabelSmall,
                                color: _parseColor(project.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (goal != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.secondaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag,
                              size: 10,
                              color: DesignTokens.secondaryPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              goal.title,
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeLabelSmall,
                                color: DesignTokens.secondaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (attribute != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TaskAttributes.getColor(attribute, isDark)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              TaskAttributes.getIcon(attribute),
                              size: 10,
                              color: TaskAttributes.getColor(attribute, isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              TaskAttributes.getDisplayName(attribute),
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeLabelSmall,
                                color: TaskAttributes.getColor(attribute, isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (todo.dueDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
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
          // 操作按钮
          PopupMenuButton(
            itemBuilder: (context) => [
              if (!todo.isDone)
                PopupMenuItem(
                  child: const Text('专注'),
                  onTap: () {
                    Get.to(() => FocusPage(taskTitle: todo.title));
                  },
                ),
              PopupMenuItem(
                child: const Text('编辑'),
                onTap: () async {
                  await Get.toNamed('/todo/add', arguments: todo);
                  _loadData();
                },
              ),
              PopupMenuItem(
                child: const Text('删除'),
                onTap: () {
                  DatabaseService.deleteTodo(todo);
                  _loadData();
                },
              ),
            ],
          ),
          // 优先级指示器
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getPriorityColor(todo.priority),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDark
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(DesignTokens.radiusXLarge),
              topRight: Radius.circular(DesignTokens.radiusXLarge),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: DesignTokens.spacing3),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.borderDark
                        : DesignTokens.borderLight,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  child: Column(
                    children: [
                      _buildCreateMenuItem(
                        icon: Icons.flag_outlined,
                        title: '创建目标',
                        onTap: () async {
                          Get.back();
                          final result = await Get.toNamed('/goal/add');
                          if (result == true) {
                            _loadData();
                          }
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      _buildCreateMenuItem(
                        icon: Icons.folder_outlined,
                        title: '创建项目',
                        onTap: () async {
                          Get.back();
                          final result = await Get.toNamed('/project/add');
                          if (result == true) {
                            _loadData();
                          }
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      _buildCreateMenuItem(
                        icon: Icons.check_circle_outline,
                        title: '创建任务',
                        onTap: () async {
                          Get.back();
                          final result = await Get.toNamed('/todo/add');
                          if (result == true) {
                            _loadData();
                          }
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.surfaceDarkSecondary
              : DesignTokens.surfaceLightSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DesignTokens.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              child: Icon(
                icon,
                color: DesignTokens.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing4),
            Expanded(
              child: Text(
                title,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? DesignTokens.textTertiaryDark
                  : DesignTokens.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateGoalProgress(Goal goal) {
    if ((goal.targetValue ?? 0) > 0 && goal.currentValue != null) {
      final valueProgress =
          (goal.currentValue! / goal.targetValue!).clamp(0.0, 1.0);
      return valueProgress;
    }

    final relatedProjects = _projects
        .where((project) => project.goalIds?.contains(goal.id) ?? false)
        .toList();
    if (relatedProjects.isNotEmpty) {
      final avgProgress = relatedProjects
              .map((project) => project.progress)
              .fold<double>(0, (sum, value) => sum + value) /
          relatedProjects.length;
      return avgProgress.clamp(0.0, 1.0);
    }

    return goal.progress.clamp(0.0, 1.0);
  }

  String _getGoalProgressSource(Goal goal) {
    if ((goal.targetValue ?? 0) > 0 && goal.currentValue != null) {
      return '基于数值';
    }
    final relatedProjects = _projects
        .where((project) => project.goalIds?.contains(goal.id) ?? false)
        .toList();
    if (relatedProjects.isNotEmpty) {
      return '关联项目';
    }
    return '手动';
  }

  // ignore: unused_element
  void _showAssociateProjects(Goal goal) {
    final selectedProjectIds = <String>{
      for (final project in _projects)
        if (project.goalIds?.contains(goal.id) ?? false) project.id,
    };

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
                color: isDark
                    ? DesignTokens.surfaceDark
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusXLarge),
                  topRight: Radius.circular(DesignTokens.radiusXLarge),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: DesignTokens.spacing3),
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacing6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '关联项目',
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeTitleLarge,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isDark
                                  ? DesignTokens.onSurfaceDark
                                  : DesignTokens.onSurfaceLight,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing4),
                          if (_projects.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(DesignTokens.spacing8),
                                child: Text(
                                  '暂无项目可关联',
                                  style: DesignTokens.textStyle(
                                    color: isDark
                                        ? DesignTokens.textSecondaryDark
                                        : DesignTokens.textSecondaryLight,
                                  ),
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: maxHeight),
                              child: ListView(
                                shrinkWrap: true,
                                children: _projects.map((project) {
                                  final isSelected =
                                      selectedProjectIds.contains(project.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(project.name),
                                    onChanged: (value) {
                                      setStateModal(() {
                                        if (value == true) {
                                          selectedProjectIds.add(project.id);
                                        } else {
                                          selectedProjectIds.remove(project.id);
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
                                await DatabaseService.setGoalProjectLinks(
                                  goal.id,
                                  selectedProjectIds.toList(),
                                );
                                Get.back();
                                _loadData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignTokens.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: DesignTokens.spacing3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(DesignTokens.radiusXLarge),
                                ),
                              ),
                              child: const Text('完成'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ignore: unused_element
  void _showAssociateTodos(Project project) {
    final selectedTodoIds = <String>{
      for (final todo in _todos)
        if (todo.projectId == project.id) todo.id,
    };

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
                color: isDark
                    ? DesignTokens.surfaceDark
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusXLarge),
                  topRight: Radius.circular(DesignTokens.radiusXLarge),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: DesignTokens.spacing3),
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacing6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '关联任务',
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeTitleLarge,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isDark
                                  ? DesignTokens.onSurfaceDark
                                  : DesignTokens.onSurfaceLight,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing4),
                          if (_todos.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(DesignTokens.spacing8),
                                child: Text(
                                  '暂无任务可关联',
                                  style: DesignTokens.textStyle(
                                    color: isDark
                                        ? DesignTokens.textSecondaryDark
                                        : DesignTokens.textSecondaryLight,
                                  ),
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: maxHeight),
                              child: ListView(
                                shrinkWrap: true,
                                children: _todos.map((todo) {
                                  final isSelected =
                                      selectedTodoIds.contains(todo.id);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(todo.title),
                                    onChanged: (value) {
                                      setStateModal(() {
                                        if (value == true) {
                                          selectedTodoIds.add(todo.id);
                                        } else {
                                          selectedTodoIds.remove(todo.id);
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
                                  selectedTodoIds.toList(),
                                );
                                Get.back();
                                _loadData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignTokens.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: DesignTokens.spacing3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(DesignTokens.radiusXLarge),
                                ),
                              ),
                              child: const Text('完成'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

