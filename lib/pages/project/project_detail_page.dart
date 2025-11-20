import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/time_indicator.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/calendar_sync_service.dart';
import 'package:praxis/common/models/todo.dart';
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
  void _refreshData() {
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
        ? project.todoIds!.map((id) {
            final todo = DatabaseService.getTodoById(id);
            return todo;
          }).whereType<Todo>().toList()
        : <Todo>[];

    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: Column(
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
                    color: isDark
                        ? DesignTokens.surfaceDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge + 8),
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
                              color: _parseColor(project.color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                              border: Border.all(
                                color: _parseColor(project.color).withOpacity(0.3),
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
                                    fontSize: DesignTokens.fontSizeHeadlineSmall,
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
                                              ? DesignTokens.surfaceDarkSecondary
                                              : DesignTokens.surfaceLightSecondary,
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                                        ),
                                        child: Text(
                                          '截止: ${project.endDate!.month}月${project.endDate!.day}日',
                                          style: DesignTokens.textStyle(
                                            fontSize: DesignTokens.fontSizeLabelSmall,
                                            color: isDark
                                                ? DesignTokens.textSecondaryDark
                                                : DesignTokens.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DesignTokens.spacing2,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: DesignTokens.secondaryOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                                      ),
                                      child: Text(
                                        '中等难度',
                                        style: DesignTokens.textStyle(
                                          fontSize: DesignTokens.fontSizeLabelSmall,
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
                
                // 执行路线图标题
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
                
                const SizedBox(height: DesignTokens.spacing6),
                
                // 阶段列表
                if (project.phases != null && project.phases!.isNotEmpty)
                  ...project.phases!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final phase = entry.value;
                    final phaseTodos = phase.todoIds != null
                        ? phase.todoIds!.map((id) {
                            final todo = DatabaseService.getTodoById(id);
                            return todo;
                          }).whereType<Todo>().toList()
                        : <Todo>[];
                    
                    final isActive = phase.status.toString().contains('active');
                    final isCompleted = phase.status.toString().contains('completed');
                    
                    return _buildPhaseSection(
                      phase.name,
                      phaseTodos,
                      isActive,
                      isCompleted,
                      index == 0,
                      index == project.phases!.length - 1,
                      isDark,
                    );
                  }),
              ],
            ),
          ),
          
          // 底部按钮
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing5),
            decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.backgroundDark
                  : Colors.white,
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
                  backgroundColor: isDark
                      ? DesignTokens.surfaceDark
                      : Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.spacing4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
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
          color: isDark
              ? DesignTokens.borderDark
              : DesignTokens.borderLight,
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

  Widget _buildPhaseSection(
    String phaseName,
    List<Todo> todos,
    bool isActive,
    bool isCompleted,
    bool isFirst,
    bool isLast,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : DesignTokens.spacing10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间轴
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 3,
                  height: 20,
                  color: isActive || isCompleted
                      ? DesignTokens.primaryColor.withOpacity(0.3)
                      : (isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight),
                ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? DesignTokens.primaryColor
                      : (isDark
                          ? DesignTokens.surfaceDarkSecondary
                          : DesignTokens.surfaceLightSecondary),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? DesignTokens.primaryColor
                        : (isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight),
                    width: 4,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color: isActive
                        ? DesignTokens.primaryColor.withOpacity(0.3)
                        : (isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight),
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
                            ? DesignTokens.primaryColor.withOpacity(0.1)
                            : (isCompleted
                                ? DesignTokens.secondaryEmerald.withOpacity(0.1)
                                : (isDark
                                    ? DesignTokens.surfaceDarkSecondary
                                    : DesignTokens.surfaceLightSecondary)),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      ),
                      child: Text(
                        isActive
                            ? '进行中'
                            : (isCompleted
                                ? '已完成'
                                : '未开始'),
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
                
                // 任务列表
                ...todos.map((todo) {
                  return _buildTaskItem(todo, isActive, isDark);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Todo todo, bool isPhaseActive, bool isDark) {
    final isToday = todo.dueDate != null &&
        todo.dueDate!.year == DateTime.now().year &&
        todo.dueDate!.month == DateTime.now().month &&
        todo.dueDate!.day == DateTime.now().day;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: GestureDetector(
        onTap: () async {
          todo.toggleDone();
          await DatabaseService.updateTodo(todo);
          
          // 更新日历同步
          await CalendarSyncService.updateTodo(todo);
          
          _refreshData();
        },
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            border: Border.all(
              color: todo.isDone
                  ? DesignTokens.secondaryEmerald.withOpacity(0.3)
                  : (isPhaseActive && isToday
                      ? DesignTokens.primaryColor.withOpacity(0.5)
                      : (isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight)),
              width: todo.isDone || (isPhaseActive && isToday) ? 2 : 1,
            ),
            boxShadow: isPhaseActive && isToday
                ? DesignTokens.shadowIOS
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: todo.isDone
                      ? DesignTokens.secondaryEmerald
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: todo.isDone
                        ? DesignTokens.secondaryEmerald
                        : (isPhaseActive && isToday
                            ? DesignTokens.primaryColor
                            : (isDark
                                ? DesignTokens.borderDark
                                : DesignTokens.borderLight)),
                    width: 2,
                  ),
                ),
                child: todo.isDone
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              
              const SizedBox(width: DesignTokens.spacing4),
              
              Expanded(
                child: Text(
                  todo.title,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyMedium,
                    fontWeight: todo.isDone
                        ? DesignTokens.fontWeightMedium
                        : DesignTokens.fontWeightBold,
                    color: todo.isDone
                        ? (isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight)
                        : (isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              if (isToday && isPhaseActive)
                TimeIndicator(date: todo.dueDate),
            ],
          ),
        ),
      ),
    );
  }
}

