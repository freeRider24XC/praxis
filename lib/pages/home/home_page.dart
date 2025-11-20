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

class _HomePageState extends State<HomePage> {
  List<Project> _activeProjects = [];
  List<Todo> _todayTodos = [];
  int _focusScore = 85;
  int _remainingHours = 2;

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

  @override
  void dispose() {
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
                  
                  // 进行中项目
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
                  ..._activeProjects.take(4).map((proj) {
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
                  
                  const SizedBox(height: DesignTokens.spacing16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

