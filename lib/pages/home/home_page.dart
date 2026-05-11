import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/constants/task_attributes.dart';
import 'package:praxis/pages/focus/focus_page.dart';
import 'package:praxis/components/dashboard/index.dart';

/// 首页概览 - Dashboard 页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _allTodos = [];
  List<Todo> _filteredTodos = [];
  List<Project> _projects = [];
  List<Goal> _goals = [];
  int _focusScore = 85;
  int _remainingHours = 2;

  // 筛选状态
  String? _selectedProjectId;
  String? _selectedGoalId;
  String? _selectedAttribute;
  TodoPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _allTodos = DatabaseService.getAllTodos();
      _projects = DatabaseService.getAllProjects();
      _goals = DatabaseService.getAllGoals();

      _applyFilters();

      // 计算专注度（基于完成任务数）
      final completed = _allTodos.where((t) => t.isDone).length;
      final total = _allTodos.length;
      if (total > 0) {
        _focusScore = ((completed / total) * 100).round();
      }

      // 计算剩余时间（简化版，基于未完成任务数）
      _remainingHours = _allTodos.where((t) => !t.isDone).length;
    });
  }

  void _applyFilters() {
    _filteredTodos = _allTodos.where((todo) {
      if (_selectedProjectId != null && todo.projectId != _selectedProjectId) {
        return false;
      }
      if (_selectedGoalId != null && todo.goalId != _selectedGoalId) {
        return false;
      }
      if (_selectedAttribute != null) {
        final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);
        if (attribute != _selectedAttribute) {
          return false;
        }
      }
      if (_selectedPriority != null && todo.priority != _selectedPriority) {
        return false;
      }
      return true;
    }).toList();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '早安';
    } else if (hour < 18) {
      return '下午好';
    } else {
      return '晚安';
    }
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekday = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][now.weekday - 1];
    return '$weekday, ${now.day} ${now.month}月';
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

  Goal? get _primaryGoal {
    // 取第一个进行中的目标，或第一个未开始的目标
    try {
      return _goals.firstWhere(
        (g) => g.status == GoalStatus.inProgress,
        orElse: () => _goals.isNotEmpty ? _goals.first : throw Exception(),
      );
    } catch (_) {
      return null;
    }
  }

  Project? get _primaryProject {
    // 取第一个进行中的项目
    try {
      return _projects.firstWhere(
        (p) => p.status == ProjectStatus.active,
        orElse: () => _projects.isNotEmpty ? _projects.first : throw Exception(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGoal = _primaryGoal;
    final primaryProject = _primaryProject;

    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部问候区域
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                  vertical: DesignTokens.spacing6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDateString(),
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeLabelSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing1),
                    Text(
                      '${_getGreeting()}, Alex ☀️',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeHeadlineSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 主目标卡片 (88pt)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: GoalSummaryCard(
                  title: primaryGoal?.title ?? '暂无目标',
                  progress: primaryGoal?.progress ?? 0.0,
                  subtitle: primaryGoal != null
                      ? '${(primaryGoal.progress * 100).round()}% 完成 · ${primaryGoal.daysRemaining} 天剩余'
                      : '点击添加主目标',
                  onTap: () {
                    if (primaryGoal != null) {
                      Get.toNamed('/goal/detail', arguments: primaryGoal.id);
                    } else {
                      Get.toNamed('/goal/add');
                    }
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing4),
            ),

            // 当前项目横幅 (72pt)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: ProjectBannerCard(
                  name: primaryProject?.name ?? '暂无项目',
                  statusText: primaryProject?.status.displayName ?? '规划中',
                  statusColor: _projectStatusColor(primaryProject?.status),
                  progress: primaryProject?.progress ?? 0.0,
                  dueDate: primaryProject?.endDate != null
                      ? _formatDueDate(primaryProject!.endDate!)
                      : null,
                  onTap: () {
                    if (primaryProject != null) {
                      Get.toNamed('/project/detail', arguments: primaryProject.id);
                    } else {
                      Get.toNamed('/project/add');
                    }
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing4),
            ),

            // GrowthSummaryBar (48pt)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: GrowthSummaryBar(
                  xp: _focusScore,
                  level: (_focusScore / 10).ceil(),
                  rewardPoints: completedRewards(),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing4),
            ),

            // ReviewEntryButton (48pt)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: ReviewEntryButton(
                  onTap: () {
                    // TODO: 跳转复盘页面
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing8),
            ),

            // 统计卡片
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: StatCard(
                  label: '今日专注度',
                  value: '$_focusScore',
                  unit: '%',
                  progress: _focusScore / 100,
                  icon: Icons.local_fire_department,
                  gradientStart: DesignTokens.primaryColor,
                  gradientEnd: DesignTokens.primaryDark,
                  badges: [
                    StatBadge(
                      text: '${_filteredTodos.where((t) => !t.isDone).length} 待办',
                      icon: Icons.check_circle,
                    ),
                    StatBadge(
                      text: '${_remainingHours}h 剩余',
                      icon: Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing8),
            ),

            // 任务列表标题和筛选
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '任务列表',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeTitleLarge,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    if (_filteredTodos.isNotEmpty)
                      Text(
                        '${_filteredTodos.length} 个任务',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall,
                          color: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing4),
            ),

            // 筛选栏
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                child: _buildFilterBar(isDark),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: DesignTokens.spacing6),
            ),

            // 任务列表
            if (_filteredTodos.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing8),
                  child: Center(
                    child: Text(
                      '暂无任务',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodyMedium,
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sortedTodos = List<Todo>.from(_filteredTodos)
                        ..sort((a, b) {
                          if (a.isDone != b.isDone) {
                            return a.isDone ? 1 : -1;
                          }
                          return b.createdAt.compareTo(a.createdAt);
                        });
                      return _buildTaskItem(sortedTodos[index], isDark);
                    },
                    childCount: _filteredTodos.length,
                  ),
                ),
              ),

            // 底部预留空间，避开 BottomNavigationBar
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Color _projectStatusColor(ProjectStatus? status) {
    if (status == null) return DesignTokens.textSecondaryLight;
    switch (status) {
      case ProjectStatus.active:
        return DesignTokens.statusActive;
      case ProjectStatus.completed:
        return DesignTokens.statusCompleted;
      case ProjectStatus.onHold:
        return DesignTokens.statusPaused;
      case ProjectStatus.cancelled:
      case ProjectStatus.archived:
        return DesignTokens.statusCancelled;
      default:
        return DesignTokens.textSecondaryLight;
    }
  }

  int completedRewards() {
    // 基于完成的任务数计算犒赏点
    final completed = _allTodos.where((t) => t.isDone).length;
    return completed * 10;
  }

  Widget _buildFilterBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: '全部',
            isSelected: _selectedProjectId == null &&
                _selectedGoalId == null &&
                _selectedAttribute == null &&
                _selectedPriority == null,
            onTap: () {
              setState(() {
                _selectedProjectId = null;
                _selectedGoalId = null;
                _selectedAttribute = null;
                _selectedPriority = null;
                _applyFilters();
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: DesignTokens.spacing2),
          if (_projects.isNotEmpty)
            PopupMenuButton<String>(
              child: _buildFilterChip(
                label: _selectedProjectId != null
                    ? _projects.firstWhere((p) => p.id == _selectedProjectId).name
                    : '项目',
                isSelected: _selectedProjectId != null,
                onTap: null,
                isDark: isDark,
              ),
              onSelected: (value) {
                setState(() {
                  _selectedProjectId = value == 'none' ? null : value;
                  _applyFilters();
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'none', child: Text('全部项目')),
                ..._projects.map((project) => PopupMenuItem(
                      value: project.id,
                      child: Text(project.name),
                    )),
              ],
            ),
          const SizedBox(width: DesignTokens.spacing2),
          if (_goals.isNotEmpty)
            PopupMenuButton<String>(
              child: _buildFilterChip(
                label: _selectedGoalId != null
                    ? _goals.firstWhere((g) => g.id == _selectedGoalId).title
                    : '目标',
                isSelected: _selectedGoalId != null,
                onTap: null,
                isDark: isDark,
              ),
              onSelected: (value) {
                setState(() {
                  _selectedGoalId = value == 'none' ? null : value;
                  _applyFilters();
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'none', child: Text('全部目标')),
                ..._goals.map((goal) => PopupMenuItem(
                      value: goal.id,
                      child: Text(goal.title),
                    )),
              ],
            ),
          const SizedBox(width: DesignTokens.spacing2),
          PopupMenuButton<String>(
            child: _buildFilterChip(
              label: _selectedAttribute != null
                  ? TaskAttributes.getDisplayName(_selectedAttribute!)
                  : '属性',
              isSelected: _selectedAttribute != null,
              onTap: null,
              isDark: isDark,
            ),
            onSelected: (value) {
              setState(() {
                _selectedAttribute = value == 'none' ? null : value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'none', child: Text('全部属性')),
              ...TaskAttributes.allAttributes.map((attr) => PopupMenuItem(
                    value: attr,
                    child: Text(TaskAttributes.getDisplayName(attr)),
                  )),
            ],
          ),
          const SizedBox(width: DesignTokens.spacing2),
          PopupMenuButton<TodoPriority>(
            child: _buildFilterChip(
              label: _selectedPriority != null
                  ? _getPriorityLabel(_selectedPriority!)
                  : '优先级',
              isSelected: _selectedPriority != null,
              onTap: null,
              isDark: isDark,
            ),
            onSelected: (value) {
              setState(() {
                _selectedPriority = value == TodoPriority.medium ? null : value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: TodoPriority.medium, child: Text('全部优先级')),
              const PopupMenuItem(value: TodoPriority.urgent, child: Text('紧急')),
              const PopupMenuItem(value: TodoPriority.high, child: Text('高')),
              const PopupMenuItem(value: TodoPriority.low, child: Text('低')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing3,
          vertical: DesignTokens.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primaryColor.withOpacity(0.1)
              : isDark
                  ? DesignTokens.surfaceDarkSecondary
                  : DesignTokens.surfaceLightSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          border: Border.all(
            color: isSelected
                ? DesignTokens.primaryColor
                : isDark
                    ? DesignTokens.borderDark
                    : DesignTokens.borderLight,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: DesignTokens.textStyle(
            fontSize: DesignTokens.fontSizeLabelSmall,
            fontWeight: isSelected ? DesignTokens.fontWeightBold : DesignTokens.fontWeightMedium,
            color: isSelected
                ? DesignTokens.primaryColor
                : isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.urgent:
        return '紧急';
      case TodoPriority.high:
        return '高';
      case TodoPriority.medium:
        return '中';
      case TodoPriority.low:
        return '低';
    }
  }

  Widget _buildTaskItem(Todo todo, bool isDark) {
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
    final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
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
        children: [
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
                      _buildTag(
                        icon: Icons.folder,
                        text: project.name,
                        color: _parseColor(project.color),
                      ),
                    if (goal != null)
                      _buildTag(
                        icon: Icons.flag,
                        text: goal.title,
                        color: DesignTokens.secondaryPurple,
                      ),
                    if (attribute != null)
                      _buildTag(
                        icon: TaskAttributes.getIcon(attribute),
                        text: TaskAttributes.getDisplayName(attribute),
                        color: TaskAttributes.getColor(attribute, isDark),
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
          if (!todo.isDone)
            IconButton(
              icon: Icon(
                Icons.timer_outlined,
                color: DesignTokens.primaryColor,
                size: 24,
              ),
              onPressed: () {
                Get.to(() => FocusPage(taskTitle: todo.title));
              },
              tooltip: '专注',
            ),
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

  Widget _buildTag({
    required IconData icon,
    required String text,
    required Color color,
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
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
