import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/pages/project/project_detail_page.dart';

/// 首页概览
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Project> _activeProjects = [];
  List<Todo> _todayTodos = [];
  int _focusScore = 85;
  int _remainingHours = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新显示时刷新数据
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _activeProjects = DatabaseService.getActiveProjects();
      _todayTodos = DatabaseService.getTodosForToday();
      
      // 计算专注度（基于今日完成任务数）
      final completedToday = _todayTodos.where((t) => t.isDone).length;
      final totalToday = _todayTodos.length;
      if (totalToday > 0) {
        _focusScore = ((completedToday / totalToday) * 100).round();
      }
      
      // 计算剩余时间（简化版，基于未完成任务数）
      _remainingHours = _todayTodos.where((t) => !t.isDone).length;
    });
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

  String _getCategoryFromTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) return 'Project';
    return tags.first.toUpperCase();
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
              child: Column(
                children: [
                  // 问候语和头像
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DesignTokens.secondaryEmerald,
                            width: 2,
                          ),
                          color: isDark
                              ? DesignTokens.surfaceDark
                              : Colors.white,
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.person,
                                color: isDark
                                    ? DesignTokens.onSurfaceDark
                                    : DesignTokens.onSurfaceLight,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: DesignTokens.secondaryEmerald,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? DesignTokens.backgroundDark
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
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
                        text: '${_todayTodos.where((t) => !t.isDone).length} 待办',
                        icon: Icons.check_circle,
                      ),
                      StatBadge(
                        text: '${_remainingHours}h 剩余',
                        icon: Icons.access_time,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: DesignTokens.spacing8),
                  
                  // Tab切换：项目和任务
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignTokens.surfaceDarkSecondary
                          : DesignTokens.surfaceLightSecondary,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: isDark
                                ? DesignTokens.surfaceDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: DesignTokens.primaryColor,
                          unselectedLabelColor: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                          labelStyle: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodyMedium,
                            fontWeight: DesignTokens.fontWeightBold,
                          ),
                          tabs: const [
                            Tab(text: '项目'),
                            Tab(text: '任务'),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // 项目Tab
                              _buildProjectsTab(isDark),
                              // 任务Tab
                              _buildTasksTab(isDark),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildProjectsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进行中',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeTitleLarge,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
            if (_activeProjects.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // 导航到项目列表
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing3,
                    vertical: DesignTokens.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                  child: Text(
                    '全部 (${_activeProjects.length})',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: DesignTokens.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: DesignTokens.spacing4),
        
        // 项目卡片列表
        ..._activeProjects.take(10).map((proj) {
          final daysRemaining = proj.endDate != null
              ? proj.endDate!.difference(DateTime.now()).inDays
              : null;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacing4),
            child: PlanCard(
              title: proj.name,
              subtitle: daysRemaining != null
                  ? '还有 $daysRemaining 天${proj.endDate != null ? " • ${proj.todoIds?.length ?? 0}/${(proj.todoIds?.length ?? 0) + (proj.phases?.fold<int>(0, (sum, phase) => sum + (phase.todoIds?.length ?? 0)) ?? 0)} 任务" : ""}'
                  : '${proj.todoIds?.length ?? 0} 任务',
              progress: proj.progress,
              color: _parseColor(proj.color),
              category: _getCategoryFromTags(proj.tags),
              onTap: () async {
                await Get.to(() => ProjectDetailPage(projectId: proj.id));
                // 返回时刷新数据
                _loadData();
              },
              trailing: IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
                onPressed: () {},
              ),
            ),
          );
        }),
        
        if (_activeProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing8),
            child: Center(
              child: Text(
                '暂无进行中的项目',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTasksTab(bool isDark) {
    final incompleteTodos = _todayTodos.where((t) => !t.isDone).toList();
    
    return ListView(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今日任务',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeTitleLarge,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
            if (_todayTodos.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // 导航到待办列表页
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing3,
                    vertical: DesignTokens.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                  child: Text(
                    '全部 (${_todayTodos.length})',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: DesignTokens.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: DesignTokens.spacing4),
        
        // 任务列表（显示未完成的优先）
        ...incompleteTodos.take(10).map((todo) {
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
                    final updatedTodo = todo.copyWith(isDone: true, completedAt: DateTime.now());
                    await DatabaseService.updateTodo(updatedTodo);
                    _loadData();
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
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: DesignTokens.spacing1),
                        Row(
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
                    ],
                  ),
                ),
                
                // 优先级指示器
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }),
        
        if (incompleteTodos.isEmpty)
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing8),
            child: Center(
              child: Text(
                '今日暂无待办任务',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

