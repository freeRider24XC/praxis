import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/todo/todo_detail_page.dart';

class GoalDetailPage extends StatefulWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  Goal? _goal;
  List<Project> _projects = [];
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await GoalRepository.recalculateProgress(widget.goalId);
    final goal = GoalRepository.getById(widget.goalId);
    if (goal == null) {
      setState(() {
        _goal = null;
        _projects = [];
        _todos = [];
      });
      return;
    }

    final projects = ProjectRepository.getAll()
        .where((project) => project.goalIds?.contains(goal.id) ?? false)
        .toList();

    final todos = TodoRepository.getByGoal(goal.id);

    setState(() {
      _goal = goal;
      _projects = projects;
      _todos = todos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final goal = _goal;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal?.title ?? '目标详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: goal == null
                ? null
                : () async {
                    final result =
                        await Get.toNamed('/goal/add', arguments: goal);
                    if (result == true) {
                      await _loadData();
                    }
                  },
            tooltip: '编辑目标',
          ),
        ],
      ),
      body: goal == null
          ? Center(
              child: Text(
                '目标不存在或已被删除',
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(DesignTokens.spacing6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(goal, isDark),
                    const SizedBox(height: DesignTokens.spacing5),
                    _buildProgressSection(goal, isDark),
                    const SizedBox(height: DesignTokens.spacing5),
                    _buildProjectsSection(goal, isDark),
                    const SizedBox(height: DesignTokens.spacing5),
                    _buildTodosSection(goal, isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(Goal goal, bool isDark) {
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing3,
                  vertical: DesignTokens.spacing1,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(goal.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                ),
                child: Text(
                  goal.status.displayName,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: _getStatusColor(goal.status),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing2),
              if (goal.status == GoalStatus.notStarted ||
                  goal.status == GoalStatus.inProgress ||
                  goal.status == GoalStatus.paused)
                TextButton.icon(
                  onPressed: () => _confirmMarkGoalCompleted(goal),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('标记完成'),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.statusCompleted,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing2,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                goal.type.displayName,
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Text(
            goal.title,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeHeadlineSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          if (goal.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              goal.description!,
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
              _buildStatTile(
                label: '开始时间',
                value: _formatDate(goal.startDate),
                isDark: isDark,
              ),
              _buildStatTile(
                label: '截止时间',
                value: _formatDate(goal.targetDate),
                isDark: isDark,
              ),
              _buildStatTile(
                label: '剩余天数',
                value: goal.daysRemaining > 0
                    ? '${goal.daysRemaining}天'
                    : (goal.isOverdue ? '已逾期' : '今天'),
                isDark: isDark,
                highlighted: goal.isOverdue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required bool isDark,
    bool highlighted = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeBodyLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: highlighted
                  ? DesignTokens.errorColor
                  : (isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Goal goal, bool isDark) {
    final computedProgress = _calculateGoalProgress(goal);
    final sourceLabel = _getGoalProgressSource(goal);
    final percent = (computedProgress * 100).clamp(0, 100).toInt();

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
              Text(
                '进度概览',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeTitleLarge,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
              Text(
                sourceLabel,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: computedProgress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  backgroundColor: isDark
                      ? DesignTokens.surfaceDarkSecondary
                      : DesignTokens.surfaceLightSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent >= 80
                        ? DesignTokens.successColor
                        : percent >= 50
                            ? DesignTokens.primaryColor
                            : percent >= 30
                                ? DesignTokens.warningColor
                                : DesignTokens.errorColor,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing4),
              Text(
                '$percent%',
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
          if (goal.targetValue != null && goal.targetValue! > 0) ...[
            const SizedBox(height: DesignTokens.spacing4),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: '目标值',
                    value:
                        '${goal.targetValue}${goal.unit != null ? goal.unit! : ''}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    title: '当前值',
                    value:
                        '${goal.currentValue ?? 0}${goal.unit != null ? goal.unit! : ''}',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing3),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showUpdateGoalValue(goal),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('更新当前进度'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing1),
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
            title,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
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
        ],
      ),
    );
  }

  Widget _buildProjectsSection(Goal goal, bool isDark) {
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
              TextButton.icon(
                onPressed: () => _showAssociateProjects(goal),
                icon: const Icon(Icons.folder_outlined, size: 16),
                label: const Text('管理'),
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          if (_projects.isEmpty)
            _buildEmptyHint('暂无关联的项目', isDark)
          else
            ..._projects.map(
              (project) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  project.name,
                  style: DesignTokens.textStyle(
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                subtitle: LinearProgressIndicator(
                  value: project.progress,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? DesignTokens.surfaceDarkSecondary
                      : DesignTokens.surfaceLightSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignTokens.primaryColor,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () async {
                    await Get.to(
                        () => ProjectDetailPage(projectId: project.id));
                    await _loadData();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodosSection(Goal goal, bool isDark) {
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
              Text(
                '${_todos.length} 条',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          if (_todos.isEmpty)
            _buildEmptyHint('暂无关联的任务，试试在任务详情中关联目标', isDark)
          else
            ..._todos.map(
              (todo) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  todo.isDone
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: todo.isDone
                      ? DesignTokens.successColor
                      : DesignTokens.textSecondaryLight,
                ),
                title: Text(
                  todo.title,
                  style: DesignTokens.textStyle(
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                subtitle: todo.dueDate != null
                    ? Text(
                        '截止 ${_formatDate(todo.dueDate!)}',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall,
                          color: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () async {
                    await Get.to(() => TodoDetailPage(todoId: todo.id));
                    await _loadData();
                  },
                ),
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

  Future<void> _confirmMarkGoalCompleted(Goal goal) async {
    if (goal.status == GoalStatus.completed ||
        goal.status == GoalStatus.cancelled) {
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('标记目标完成'),
        content: Text(
          '完成「${goal.title}」后将发放 +${XpService.goalCompletedXp} XP 和 '
          '+${PraisePointsCalculator.forGoal()} 犒赏点，且不能撤销。确认继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.statusCompleted,
            ),
            child: const Text('确认完成'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    goal.status = GoalStatus.completed;
    goal.progress = 1.0;
    goal.updatedAt = DateTime.now();
    await GoalRepository.update(goal);
    await XpService.awardGoalCompleted(goal);
    await _loadData();
  }

  void _showUpdateGoalValue(Goal goal) {
    final currentController = TextEditingController(
      text: goal.currentValue?.toString() ?? '',
    );
    final targetController = TextEditingController(
      text: goal.targetValue?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
              padding: EdgeInsets.only(
                left: DesignTokens.spacing6,
                right: DesignTokens.spacing6,
                top: DesignTokens.spacing6,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    DesignTokens.spacing6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '更新目标数值',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleLarge,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '目标值',
                      hintText: '例如：1000000',
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  TextField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '当前进度值',
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final targetValue =
                            int.tryParse(targetController.text.trim());
                        final currentValue =
                            int.tryParse(currentController.text.trim());

                        if (targetValue != null && targetValue > 0) {
                          goal.targetValue = targetValue;
                        }
                        if (currentValue != null) {
                          goal.currentValue = currentValue;
                        }

                        await GoalRepository.update(goal);
                        await GoalRepository.recalculateProgress(goal.id);
                        Get.back();
                        await _loadData();
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
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAssociateProjects(Goal goal) {
    final selectedIds = <String>{
      ...?_goal?.projectIds,
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final maxHeight = MediaQuery.of(context).size.height * 0.7;
        final projects = ProjectRepository.getAll();
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
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusRound),
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
                          if (projects.isEmpty)
                            _buildEmptyHint('暂无项目可关联', isDark)
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: maxHeight),
                              child: ListView(
                                shrinkWrap: true,
                                children: projects.map((project) {
                                  final checked =
                                      selectedIds.contains(project.id);
                                  return CheckboxListTile(
                                    value: checked,
                                    title: Text(project.name),
                                    onChanged: (value) {
                                      setStateModal(() {
                                        if (value == true) {
                                          selectedIds.add(project.id);
                                        } else {
                                          selectedIds.remove(project.id);
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
                                await GoalRepository.setProjectLinks(
                                  goal.id,
                                  selectedIds.toList(),
                                );
                                Get.back();
                                await _loadData();
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _calculateGoalProgress(Goal goal) {
    if ((goal.targetValue ?? 0) > 0 && goal.currentValue != null) {
      return (goal.currentValue! / goal.targetValue!).clamp(0.0, 1.0);
    }

    if (_projects.isNotEmpty) {
      final avg = _projects.fold<double>(
            0,
            (sum, project) => sum + project.progress,
          ) /
          _projects.length;
      return avg.clamp(0.0, 1.0);
    }

    return goal.progress.clamp(0.0, 1.0);
  }

  String _getGoalProgressSource(Goal goal) {
    if ((goal.targetValue ?? 0) > 0 && goal.currentValue != null) {
      return '来自数值';
    }
    if (_projects.isNotEmpty) {
      return '来自项目';
    }
    return '手动';
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.notStarted:
        return Colors.grey;
      case GoalStatus.inProgress:
        return DesignTokens.statusActive;
      case GoalStatus.paused:
        return DesignTokens.statusPaused;
      case GoalStatus.completed:
        return DesignTokens.statusCompleted;
      case GoalStatus.cancelled:
        return DesignTokens.statusCancelled;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
