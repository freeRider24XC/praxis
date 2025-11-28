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

/// 首页概览 - 以任务列表为主
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
    // 当页面重新显示时刷新数据
    _loadData();
  }

  void _loadData() {
    setState(() {
      _allTodos = DatabaseService.getAllTodos();
      _projects = DatabaseService.getAllProjects();
      _goals = DatabaseService.getAllGoals();
      
      // 应用筛选
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
      // 按项目筛选
      if (_selectedProjectId != null && todo.projectId != _selectedProjectId) {
        return false;
      }

      // 按目标筛选
      if (_selectedGoalId != null && todo.goalId != _selectedGoalId) {
        return false;
      }

      // 按属性筛选
      if (_selectedAttribute != null) {
        final attribute = TaskAttributes.extractAttributeFromTags(todo.tags);
        if (attribute != _selectedAttribute) {
          return false;
        }
      }

      // 按优先级筛选
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
            // 顶部区域
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing6,
                vertical: DesignTokens.spacing6,
              ),
              color: isDark
                  ? DesignTokens.backgroundDark
                  : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 问候语
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDateString(),
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing1),
                      Text(
                        '${_getGreeting()}, Alex ☀️',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeHeadlineSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
                        ),
                      ),
                    ],
                  ),
                  
                  // 占位空间，确保创建按钮在右侧有足够空间
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing6,
                ),
                children: [
                  const SizedBox(height: DesignTokens.spacing6),
                  
                  // 统计卡片
                  StatCard(
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
                  
                  const SizedBox(height: DesignTokens.spacing8),
                  
                  // 任务列表标题和筛选
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '任务列表',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeTitleLarge,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      if (_filteredTodos.isNotEmpty)
                        Text(
                          '${_filteredTodos.length} 个任务',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeLabelSmall,
                            color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacing4),

                  // 筛选栏
                  _buildFilterBar(isDark),

                  const SizedBox(height: DesignTokens.spacing6),

                  // 任务列表
                  ..._buildTaskList(isDark),

                  if (_filteredTodos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing8),
                      child: Center(
                        child: Text(
                          '暂无任务',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodyMedium,
                            color: isDark ? DesignTokens.textSecondaryDark : DesignTokens.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: DesignTokens.spacing16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 全部
          _buildFilterChip(
            label: '全部',
            isSelected: _selectedProjectId == null && _selectedGoalId == null && _selectedAttribute == null && _selectedPriority == null,
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

          // 按项目筛选
          if (_projects.isNotEmpty)
            PopupMenuButton<String>(
              child: _buildFilterChip(
                label: _selectedProjectId != null ? _projects.firstWhere((p) => p.id == _selectedProjectId).name : '项目',
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

          // 按目标筛选
          if (_goals.isNotEmpty)
            PopupMenuButton<String>(
              child: _buildFilterChip(
                label: _selectedGoalId != null ? _goals.firstWhere((g) => g.id == _selectedGoalId).title : '目标',
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

          // 按属性筛选
          PopupMenuButton<String>(
            child: _buildFilterChip(
              label: _selectedAttribute != null ? TaskAttributes.getDisplayName(_selectedAttribute!) : '属性',
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

          // 按优先级筛选
          PopupMenuButton<TodoPriority>(
            child: _buildFilterChip(
              label: _selectedPriority != null ? _getPriorityLabel(_selectedPriority!) : '优先级',
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

  List<Widget> _buildTaskList(bool isDark) {
    // 按未完成优先排序
    final sortedTodos = List<Todo>.from(_filteredTodos)
      ..sort((a, b) {
        if (a.isDone != b.isDone) {
          return a.isDone ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });

    return sortedTodos.map((todo) {
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
            // 复选框
            GestureDetector(
              onTap: () async {
                // 获取原始todo对象（已在box中）
                final originalTodo = DatabaseService.getTodoById(todo.id);
                if (originalTodo != null) {
                  // 更新原始对象的属性
                  originalTodo.isDone = !originalTodo.isDone;
                  originalTodo.completedAt = originalTodo.isDone ? DateTime.now() : null;
                  originalTodo.updatedAt = DateTime.now();
                  // 保存更新
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
                      color: isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
                    ).copyWith(
                      decoration: todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  const SizedBox(height: DesignTokens.spacing2),

                  // 关联信息行
                  Wrap(
                    spacing: DesignTokens.spacing2,
                    runSpacing: DesignTokens.spacing1,
                    children: [
                      // 关联项目
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

                      // 关联目标
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

                      // 属性标签
                      if (attribute != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacing2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TaskAttributes.getColor(attribute, isDark).withOpacity(0.1),
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

                      // 截止时间
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

            // 专注按钮
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
    }).toList();
  }
}

