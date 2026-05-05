import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/ai_chat/ai_plan_page.dart';
import 'package:praxis/pages/goal/add_goal_page.dart';
import 'package:praxis/pages/goal/goal_detail_page.dart';
import 'package:praxis/pages/project/add_project_page.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/todo/add_todo_page.dart';
import 'package:praxis/pages/todo/todo_detail_page.dart';

class DomainDetailPage extends StatefulWidget {
  final String domainId;

  const DomainDetailPage({
    super.key,
    required this.domainId,
  });

  @override
  State<DomainDetailPage> createState() => _DomainDetailPageState();
}

class _DomainDetailPageState extends State<DomainDetailPage> {
  LifeDomain? _domain;
  List<Goal> _goals = const [];
  List<Project> _projects = const [];
  List<Todo> _todos = const [];
  List<Todo> _todayTodos = const [];
  bool _isFocused = false;
  double _weeklyProgress = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final domain = DomainService.getDomainById(widget.domainId);
    final profile = ProfileService.getProfile();
    final goals = DatabaseService.getGoalsByDomain(widget.domainId);
    final projects = DatabaseService.getProjectsByDomain(widget.domainId);
    final todos = DatabaseService.getTodosByDomain(widget.domainId);
    final today = DateTime.now();
    final todayTodos = todos.where((todo) {
      if (todo.isDone || todo.dueDate == null) return false;
      final due = todo.dueDate!;
      return due.year == today.year &&
          due.month == today.month &&
          due.day == today.day;
    }).toList();

    double weeklyProgress = 0;
    if (profile.focusedDomainId == widget.domainId) {
      weeklyProgress = ProfileService.getFocusedDomainWeeklyProgress();
    } else {
      final startOfWeek = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      final weeklyTodos = todos.where((todo) {
        if (todo.dueDate == null) return false;
        final due = todo.dueDate!;
        return due.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            due.isBefore(endOfWeek);
      }).toList();
      if (weeklyTodos.isNotEmpty) {
        final completed = weeklyTodos.where((todo) => todo.isDone).length;
        weeklyProgress = completed / weeklyTodos.length;
      }
    }

    if (!mounted) return;
    setState(() {
      _domain = domain;
      _goals = goals;
      _projects = projects;
      _todos = todos;
      _todayTodos = todayTodos;
      _isFocused = profile.focusedDomainId == widget.domainId;
      _weeklyProgress = weeklyProgress;
    });
  }

  Future<void> _setFocusedDomain() async {
    await DomainService.setFocusedDomain(widget.domainId);
    await _load();
  }

  Future<void> _openAiPlanning() async {
    if (!_isFocused) {
      await DomainService.setFocusedDomain(widget.domainId);
    }
    await Get.to(() => const AiPlanPage(initialGoalText: ''));
    await _load();
  }

  Future<void> _toggleTodo(Todo todo) async {
    final wasDone = todo.isDone;
    todo.toggleDone();
    await DatabaseService.updateTodo(todo);
    if (!wasDone && todo.isDone) {
      await XpService.awardTodoCompleted(todo);
    }
    await _load();
  }

  Future<void> _createGoal() async {
    await Get.to(() => AddGoalPage(initialDomainId: widget.domainId));
    await _load();
  }

  Future<void> _createProject() async {
    await Get.to(() => AddProjectPage(initialDomainId: widget.domainId));
    await _load();
  }

  Future<void> _createTodo() async {
    await Get.to(() => AddTodoPage(initialDomainId: widget.domainId));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final domain = _domain;

    if (domain == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('领域不存在')),
        body: const Center(child: Text('领域不存在或已被删除')),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacing6,
              DesignTokens.spacing4,
              DesignTokens.spacing6,
              DesignTokens.spacing10,
            ),
            children: [
              _buildHeader(domain, isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildHeroCard(domain, isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildQuickActionsCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildStatsRow(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildGoalsSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildProjectsSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildTodosSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LifeDomain domain, bool isDark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '领域工作台',
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
                '${domain.icon} ${domain.name}',
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
        ),
        const SizedBox(width: DesignTokens.spacing3),
        OutlinedButton(
          onPressed: _isFocused ? null : _setFocusedDomain,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: _isFocused
                  ? DesignTokens.primaryColor
                  : (isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight),
            ),
            foregroundColor: DesignTokens.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
          ),
          child: Text(_isFocused ? '当前重点' : '设为重点'),
        ),
      ],
    );
  }

  Widget _buildHeroCard(LifeDomain domain, bool isDark) {
    final progressPercent = (_weeklyProgress * 100).round();
    final activeGoal =
        _goals.where((goal) => goal.status == GoalStatus.inProgress).toList();
    final topGoal = activeGoal.isNotEmpty
        ? activeGoal.first
        : (_goals.isNotEmpty ? _goals.first : null);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DesignTokens.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  domain.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isFocused ? '当前重点领域' : '可切换为本周重点',
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
                      '$progressPercent% 本周推进中',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodyLarge,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            child: LinearProgressIndicator(
              value: _weeklyProgress,
              minHeight: 10,
              backgroundColor: isDark
                  ? DesignTokens.surfaceDarkSecondary
                  : DesignTokens.surfaceLightSecondary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                DesignTokens.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Text(
            topGoal == null ? '当前还没有这个领域的目标。' : '当前最值得推进：${topGoal.title}',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAiPlanning,
              icon: const Icon(Icons.auto_awesome),
              label: Text(_isFocused ? '从这个领域发起 AI 规划' : '设为重点并发起 AI 规划'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final completedTodos = _todos.where((todo) => todo.isDone).length;
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            isDark: isDark,
            label: '目标',
            value: '${_goals.length}',
          ),
        ),
        const SizedBox(width: DesignTokens.spacing3),
        Expanded(
          child: _buildStatTile(
            isDark: isDark,
            label: '项目',
            value: '${_projects.length}',
          ),
        ),
        const SizedBox(width: DesignTokens.spacing3),
        Expanded(
          child: _buildStatTile(
            isDark: isDark,
            label: '完成任务',
            value: '$completedTodos/${_todos.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '从这里继续推进',
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
            '直接把新目标、项目和任务落到这个领域里。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  isDark: isDark,
                  icon: Icons.flag_outlined,
                  label: '新目标',
                  onTap: _createGoal,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _buildQuickActionButton(
                  isDark: isDark,
                  icon: Icons.folder_outlined,
                  label: '新项目',
                  onTap: _createProject,
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _buildQuickActionButton(
                  isDark: isDark,
                  icon: Icons.check_circle_outline,
                  label: '新任务',
                  onTap: _createTodo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing3,
          vertical: DesignTokens.spacing4,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.surfaceDarkSecondary
              : DesignTokens.surfaceLightSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          border: Border.all(
            color: isDark
                ? DesignTokens.borderDark
                : DesignTokens.borderLight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: DesignTokens.primaryColor,
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              label,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeLabelSmall,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
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

  Widget _buildGoalsSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '这个领域的目标',
      actionLabel: '${_goals.length} 个',
      child: _goals.isEmpty
          ? _buildEmptyHint(
              isDark,
              '还没有这个领域的目标，先用 AI 规划出一个方向。',
            )
          : Column(
              children: _goals.take(3).map((goal) {
                return _buildListItem(
                  isDark: isDark,
                  icon: Icons.flag_outlined,
                  title: goal.title,
                  subtitle: goal.status.displayName,
                  trailing: '${(goal.progress * 100).round()}%',
                  onTap: () async {
                    await Get.to(() => GoalDetailPage(goalId: goal.id));
                    await _load();
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget _buildProjectsSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '相关项目',
      actionLabel: '${_projects.length} 个',
      child: _projects.isEmpty
          ? _buildEmptyHint(
              isDark,
              '这个领域还没有项目，先生成一个可执行计划。',
            )
          : Column(
              children: _projects.take(3).map((project) {
                return _buildListItem(
                  isDark: isDark,
                  icon: Icons.folder_outlined,
                  title: project.name,
                  subtitle: project.status.displayName,
                  trailing: '${(project.progress * 100).round()}%',
                  onTap: () async {
                    await Get.to(
                        () => ProjectDetailPage(projectId: project.id));
                    await _load();
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTodosSection(bool isDark) {
    final taskList = _todayTodos.isNotEmpty
        ? _todayTodos
        : _todos.where((todo) => !todo.isDone).take(5).toList();
    return _buildSectionCard(
      isDark: isDark,
      title: _todayTodos.isNotEmpty ? '今天在这个领域推进什么' : '下一步任务',
      actionLabel: '${taskList.length} 条',
      child: taskList.isEmpty
          ? _buildEmptyHint(
              isDark,
              '这个领域还没有待办任务，先创建第一周动作。',
            )
          : Column(
              children: taskList.map((todo) {
                return _buildTaskItem(
                  todo: todo,
                  isDark: isDark,
                );
              }).toList(),
            ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required Widget child,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeTitleLarge,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
              ),
              if (actionLabel != null)
                Text(
                  actionLabel,
                  style: DesignTokens.textStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          child,
        ],
      ),
    );
  }

  Widget _buildListItem({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: DesignTokens.primaryColor),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        trailing,
        style: DesignTokens.textStyle(
          fontWeight: DesignTokens.fontWeightBold,
          color:
              isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight,
        ),
      ),
    );
  }

  Widget _buildTaskItem({
    required Todo todo,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () async {
        await Get.to(() => TodoDetailPage(todoId: todo.id));
        await _load();
      },
      leading: Checkbox(
        value: todo.isDone,
        onChanged: (_) => _toggleTodo(todo),
      ),
      title: Text(
        todo.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        todo.dueDate == null
            ? todo.priority.displayName
            : '截止 ${todo.dueDate!.month}/${todo.dueDate!.day} · ${todo.priority.displayName}',
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildEmptyHint(bool isDark, String text) {
    return Text(
      text,
      style: DesignTokens.textStyle(
        color: isDark
            ? DesignTokens.textSecondaryDark
            : DesignTokens.textSecondaryLight,
      ),
    );
  }
}
