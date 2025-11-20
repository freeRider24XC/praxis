import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:get/get.dart';
import 'package:praxis/pages/todo/quick_add_modal.dart';

/// 日程视图页
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentDate = DateTime.now();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    setState(() {
      _todos = DatabaseService.getAllTodos()
          .where((todo) => todo.dueDate != null && !todo.isDone)
          .toList();
    });
  }

  List<Todo> _getTodosForDate(DateTime date) {
    return _todos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == date.year &&
          todo.dueDate!.month == date.month &&
          todo.dueDate!.day == date.day;
    }).toList();
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startOfWeek = _currentDate.subtract(Duration(days: _currentDate.weekday - 1));
    final weekDates = List.generate(5, (index) => startOfWeek.add(Duration(days: index)));
    final selectedDateIndex = weekDates.indexWhere((date) =>
        date.year == _currentDate.year &&
        date.month == _currentDate.month &&
        date.day == _currentDate.day);
    
    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : Colors.white,
      body: Column(
        children: [
          // 顶部日期导航
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing6,
              vertical: DesignTokens.spacing2,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.backgroundDark
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentDate.month}月 ${_currentDate.year}',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeHeadlineSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentDate = _currentDate.subtract(const Duration(days: 7));
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentDate = _currentDate.add(const Duration(days: 7));
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: DesignTokens.spacing4),
                
                // 周视图
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekDates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final date = entry.value;
                    final isSelected = index == selectedDateIndex;
                    final dayTodos = _getTodosForDate(date);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentDate = date;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            _getWeekdayName(date.weekday),
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeLabelSmall,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isSelected
                                  ? DesignTokens.primaryColor
                                  : (isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight),
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing3),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DesignTokens.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeBodySmall,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? DesignTokens.textSecondaryDark
                                          : DesignTokens.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 时间轴内容
          Expanded(
            child: Container(
              color: isDark
                  ? DesignTokens.backgroundDark
                  : DesignTokens.backgroundLight,
              child: ListView(
                padding: const EdgeInsets.only(
                  left: DesignTokens.spacing6,
                  right: DesignTokens.spacing6,
                  top: DesignTokens.spacing6,
                ),
                children: [
                  // 时间线
                  Stack(
                    children: [
                      // 虚线
                      Positioned(
                        left: 72,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: isDark
                                    ? DesignTokens.borderDark
                                    : DesignTokens.borderLight,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // 任务列表
                      Column(
                        children: [
                          _buildTimeSlot('10:00', _getTodosForDate(_currentDate), isDark),
                          _buildTimeSlot('14:00', _getTodosForDate(_currentDate), isDark),
                          _buildTimeSlot('16:30', _getTodosForDate(_currentDate), isDark),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const QuickAddModal(),
          );
          // 返回时刷新数据
          _loadTodos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimeSlot(String time, List<Todo> todos, bool isDark) {
    // 简化版：显示该时间段的任务
    final timeTodos = todos.take(2).toList();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeLabelSmall,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ),
          ),
          
          const SizedBox(width: DesignTokens.spacing5),
          
          Expanded(
            child: Column(
              children: timeTodos.map((todo) {
                final isFocus = todo.priority == TodoPriority.high || todo.priority == TodoPriority.urgent;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacing4),
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.spacing4),
                    decoration: BoxDecoration(
                      color: isFocus
                          ? DesignTokens.primaryColor
                          : (isDark
                              ? DesignTokens.surfaceDark
                              : Colors.white),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                      border: isFocus
                          ? null
                          : Border.all(
                              color: _getPriorityColor(todo.priority),
                              width: 4,
                            ),
                      boxShadow: isFocus
                          ? DesignTokens.shadowFloat
                          : DesignTokens.shadowIOS,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeBodySmall,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: isFocus
                                      ? Colors.white
                                      : (isDark
                                          ? DesignTokens.onSurfaceDark
                                          : DesignTokens.onSurfaceLight),
                                ),
                              ),
                            ),
                            if (isFocus)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spacing2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                                ),
                                child: Text(
                                  '专注',
                                  style: DesignTokens.textStyle(
                                    fontSize: 10,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spacing1),
                        Text(
                          '${_getDuration(todo)} • ${_getCategory(todo)}',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeLabelSmall,
                            color: isFocus
                                ? Colors.white.withOpacity(0.8)
                                : (isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
      case TodoPriority.urgent:
        return DesignTokens.primaryColor;
      case TodoPriority.medium:
        return DesignTokens.secondaryOrange;
      case TodoPriority.low:
        return DesignTokens.secondaryEmerald;
    }
  }

  String _getDuration(Todo todo) {
    // 简化版，返回固定时长
    return '45 min';
  }

  String _getCategory(Todo todo) {
    if (todo.projectId != null) {
      return '学习计划';
    }
    return '待办事项';
  }
}
