import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/goal/goal_detail_page.dart';
import 'package:praxis/pages/goal/goal_page.dart';
import 'package:praxis/pages/project/add_project_page.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/review/daily_review_page.dart';
import 'package:praxis/pages/todo/add_todo_page.dart';
import 'package:praxis/pages/todo/todo_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserProfile? _profile;
  Goal? _currentGoal;
  Project? _currentProject;
  List<Todo> _todayTodos = [];
  List<XpEvent> _xpEvents = [];
  DailyReview? _todayReview;

  @override
  void initState() {
    super.initState();
    DataChangeNotifier.revision.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    DataChangeNotifier.revision.removeListener(_loadData);
    super.dispose();
  }

  Future<void> _loadData() async {
    final profile = ProfileService.getProfile();
    final goals = GoalRepository.getAll();
    final projects = ProjectRepository.getAll();
    final xpEvents = DatabaseService.getAllXpEvents().take(4).toList();
    final review = DatabaseService.getDailyReviewByDate(DateTime.now());

    Goal? currentGoal;
    final activeGoals =
        goals.where((goal) => goal.status == GoalStatus.inProgress).toList();
    activeGoals.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (activeGoals.isNotEmpty) {
      currentGoal = activeGoals.first;
    } else {
      final pendingGoals =
          goals.where((goal) => goal.status == GoalStatus.notStarted).toList();
      pendingGoals.sort((a, b) => a.targetDate.compareTo(b.targetDate));
      if (pendingGoals.isNotEmpty) {
        currentGoal = pendingGoals.first;
      }
    }

    Project? currentProject;
    if (currentGoal != null) {
      final goalProjects = projects
          .where(
              (project) => project.goalIds?.contains(currentGoal!.id) ?? false)
          .toList();
      goalProjects.sort((a, b) {
        final aActive = a.status == ProjectStatus.active ? 0 : 1;
        final bActive = b.status == ProjectStatus.active ? 0 : 1;
        if (aActive != bActive) return aActive.compareTo(bActive);
        if (a.endDate != null && b.endDate != null) {
          return a.endDate!.compareTo(b.endDate!);
        }
        if (a.endDate != null) return -1;
        if (b.endDate != null) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      if (goalProjects.isNotEmpty) {
        currentProject = goalProjects.first;
      }
    }

    final todayTodos = currentProject != null
        ? TodoRepository.getByProject(currentProject.id)
            .where((todo) => !todo.isDone)
            .toList()
        : TodoRepository.getTopForToday(limit: 5);

    todayTodos.sort((a, b) {
      final priorityCompare = b.priority.value.compareTo(a.priority.value);
      if (priorityCompare != 0) return priorityCompare;
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _currentGoal = currentGoal;
      _currentProject = currentProject;
      _todayTodos = todayTodos.take(5).toList();
      _xpEvents = xpEvents;
      _todayReview = review;
    });
  }

  Future<void> _toggleTodo(Todo todo) async {
    final wasDone = todo.isDone;
    todo.toggleDone();
    await TodoRepository.update(todo);
    if (!wasDone && todo.isDone) {
      await XpService.awardTodoCompleted(todo);
    }
    await _loadData();
  }

  Future<void> _openDailyReview() async {
    await Get.to(() => const DailyReviewPage());
    await _loadData();
  }

  Future<void> _createProjectForGoal() async {
    final goalId = _currentGoal?.id;
    if (goalId == null) return;
    await Get.to(
      () => AddProjectPage(
        initialDomainId: _currentGoal?.domainId,
        initialGoalId: goalId,
      ),
    );
    await _loadData();
  }

  Future<void> _createTodoForProject() async {
    final projectId = _currentProject?.id;
    if (projectId == null) return;
    await Get.to(
      () => AddTodoPage(
        initialDomainId: _currentProject?.domainId,
        initialProjectId: projectId,
      ),
    );
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = _profile;
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacing6,
              DesignTokens.spacing6,
              DesignTokens.spacing6,
              DesignTokens.spacing10,
            ),
            children: [
              _buildHeader(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildGrowthSnapshot(isDark, profile),
              const SizedBox(height: DesignTokens.spacing5),
              _buildNextActionStrip(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildCurrentGoalCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildCurrentProjectCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildTodayTodoSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildReviewCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildRecentXpSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Praxis',
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
                _currentGoal == null ? '先定目标，再拆项目和事项' : '今天先把主线往前推一步',
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
        const SizedBox(width: DesignTokens.spacing4),
        _buildHeaderAction(
          isDark: isDark,
          icon: Icons.history,
          label: '复盘',
          onTap: _openDailyReview,
          highlighted: true,
        ),
      ],
    );
  }

  Widget _buildNextActionStrip(bool isDark) {
    final hasGoal = _currentGoal != null;
    final hasProject = _currentProject != null;

    final label = !hasGoal
        ? '先确定一个当前目标'
        : !hasProject
            ? '把目标拆成一个项目'
            : '给当前项目补一个事项';

    final action = !hasGoal
        ? () async {
            await Get.to(() => const GoalPage());
            await _loadData();
          }
        : (!hasProject ? _createProjectForGoal : _createTodoForProject);

    final actionLabel = !hasGoal ? '去目标页' : (!hasProject ? '新建项目' : '新建事项');

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DesignTokens.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            child: const Icon(
              Icons.bolt,
              color: DesignTokens.primaryColor,
            ),
          ),
          const SizedBox(width: DesignTokens.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '下一步',
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
                  label,
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
          const SizedBox(width: DesignTokens.spacing3),
          TextButton(
            onPressed: action,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final backgroundColor = highlighted
        ? DesignTokens.primaryColor
        : (isDark ? DesignTokens.surfaceDark : Colors.white);
    final foregroundColor = highlighted
        ? Colors.white
        : (isDark ? DesignTokens.onSurfaceDark : DesignTokens.onSurfaceLight);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing4,
          vertical: DesignTokens.spacing3,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          border: highlighted
              ? null
              : Border.all(
                  color: isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight,
                ),
          boxShadow: highlighted ? DesignTokens.shadowFloat : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: DesignTokens.iconSizeMedium, color: foregroundColor),
            const SizedBox(height: DesignTokens.spacing1),
            Text(
              label,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeLabelSmall,
                fontWeight: DesignTokens.fontWeightBold,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSnapshot(bool isDark, UserProfile profile) {
    final levelProgress = XpService.xpIntoCurrentLevel(profile.totalXp);
    final levelMax = XpService.xpNeededWithinCurrentLevel(profile.totalXp);
    final progress =
        levelMax == 0 ? 0.0 : (levelProgress / levelMax).clamp(0.0, 1.0);

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
            '成长状态',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            'Lv.${profile.level} · 已累计 ${profile.totalXp} XP',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark
                  ? DesignTokens.surfaceDarkSecondary
                  : DesignTokens.surfaceLightSecondary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                DesignTokens.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  isDark: isDark,
                  label: '连续活跃',
                  value: '${profile.streakDays} 天',
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: _buildMetricTile(
                  isDark: isDark,
                  label: '本周投入',
                  value: '${profile.weeklyCapacityHours} h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Container(
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
            label,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing1),
          Text(
            value,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleMedium,
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

  Widget _buildCurrentGoalCard(bool isDark) {
    final goal = _currentGoal;
    return _buildSectionCard(
      isDark: isDark,
      title: '当前主目标',
      actionLabel: goal == null ? null : '查看详情',
      onActionTap: goal == null
          ? null
          : () async {
              await Get.to(() => GoalDetailPage(goalId: goal.id));
              await _loadData();
            },
      child: goal == null
          ? _buildEmptyState(
              isDark: isDark,
              text: '还没有明确主目标，先去确定这阶段最想推进的结果。',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeTitleLarge,
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
                _buildProgressBlock(
                  isDark: isDark,
                  progress: goal.progress,
                  meta:
                      '${goal.status.displayName} · 截止 ${goal.targetDate.month}/${goal.targetDate.day}',
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentProjectCard(bool isDark) {
    final project = _currentProject;
    return _buildSectionCard(
      isDark: isDark,
      title: '当前推进项目',
      actionLabel: project == null ? null : '查看详情',
      onActionTap: project == null
          ? null
          : () async {
              await Get.to(() => ProjectDetailPage(projectId: project.id));
              await _loadData();
            },
      child: project == null
          ? _buildEmptyState(
              isDark: isDark,
              text: '还没有进入具体项目推进，先把主目标拆成 1-3 个项目。',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    const SizedBox(width: DesignTokens.spacing3),
                    _buildStatusChip(
                      label: project.status.displayName,
                      color: _projectStatusColor(project.status),
                      isDark: isDark,
                    ),
                  ],
                ),
                if (project.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: DesignTokens.spacing2),
                  Text(
                    project.description!,
                    style: DesignTokens.textStyle(
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: DesignTokens.spacing4),
                _buildProgressBlock(
                  isDark: isDark,
                  progress: project.progress,
                  meta: project.endDate == null
                      ? '${_countOpenTodos(project)} 个待完成事项'
                      : '截止 ${project.endDate!.month}/${project.endDate!.day} · ${_countOpenTodos(project)} 个待完成事项',
                ),
              ],
            ),
    );
  }

  Widget _buildTodayTodoSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '今日事项',
      child: _todayTodos.isEmpty
          ? _buildEmptyState(
              isDark: isDark,
              text: '今天还没有挂在当前项目下的事项，先去补充接下来要做的动作。',
            )
          : Column(
              children: _todayTodos.map((todo) {
                return _buildTodoRow(isDark, todo);
              }).toList(),
            ),
    );
  }

  Widget _buildTodoRow(bool isDark, Todo todo) {
    final project = todo.projectId == null
        ? null
        : ProjectRepository.getById(todo.projectId!);
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: InkWell(
        onTap: () async {
          await Get.to(() => TodoDetailPage(todoId: todo.id));
          await _loadData();
        },
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDarkSecondary
                : DesignTokens.surfaceLightSecondary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: todo.isDone,
                onChanged: (_) => _toggleTodo(todo),
              ),
              const SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodyLarge,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing2),
                    Wrap(
                      spacing: DesignTokens.spacing2,
                      runSpacing: DesignTokens.spacing2,
                      children: [
                        _buildStatusChip(
                          label: todo.priority.displayName,
                          color: _priorityColor(todo.priority),
                          isDark: isDark,
                        ),
                        if (project != null)
                          _buildStatusChip(
                            label: project.name,
                            color: _parseHexColor(project.color),
                            isDark: isDark,
                          ),
                        if (todo.dueDate != null)
                          _buildStatusChip(
                            label:
                                '${todo.dueDate!.month}/${todo.dueDate!.day}',
                            color: DesignTokens.secondaryPurple,
                            isDark: isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(bool isDark) {
    final completed = _todayReview?.isCompleted ?? false;
    return _buildSectionCard(
      isDark: isDark,
      title: '今日复盘',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            completed ? '今天的复盘已经完成，明天的重点已经接出来了。' : '睡前花一分钟，总结今天并顺出明天最重要的一步。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openDailyReview,
              child: Text(completed ? '查看今日复盘' : '去完成今日复盘'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentXpSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '最近成长记录',
      child: _xpEvents.isEmpty
          ? _buildEmptyState(
              isDark: isDark,
              text: '完成一次事项后，这里会开始记录你的成长反馈。',
            )
          : Column(
              children: _xpEvents.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryColor
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusRound,
                          ),
                        ),
                        child: Text(
                          '+${event.xp}',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeLabelMedium,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: DesignTokens.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.description,
                              style: DesignTokens.textStyle(
                                fontWeight: DesignTokens.fontWeightMedium,
                                color: isDark
                                    ? DesignTokens.onSurfaceDark
                                    : DesignTokens.onSurfaceLight,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spacing1),
                            Text(
                              '${event.createdAt.month}/${event.createdAt.day} ${event.createdAt.hour.toString().padLeft(2, '0')}:${event.createdAt.minute.toString().padLeft(2, '0')}',
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
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildProgressBlock({
    required bool isDark,
    required double progress,
    required String meta,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: isDark
                ? DesignTokens.surfaceDarkSecondary
                : DesignTokens.surfaceLightSecondary,
            valueColor: const AlwaysStoppedAnimation<Color>(
              DesignTokens.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).round()}%',
              style: DesignTokens.textStyle(
                fontWeight: DesignTokens.fontWeightBold,
                color: DesignTokens.primaryColor,
              ),
            ),
            Flexible(
              child: Text(
                meta,
                textAlign: TextAlign.right,
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing2,
        vertical: DesignTokens.spacing1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
      ),
      child: Text(
        label,
        style: DesignTokens.textStyle(
          fontSize: DesignTokens.fontSizeLabelSmall,
          fontWeight: DesignTokens.fontWeightBold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required String text,
  }) {
    return Text(
      text,
      style: DesignTokens.textStyle(
        color: isDark
            ? DesignTokens.textSecondaryDark
            : DesignTokens.textSecondaryLight,
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required Widget child,
    String? actionLabel,
    VoidCallback? onActionTap,
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
              if (actionLabel != null && onActionTap != null)
                TextButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          child,
        ],
      ),
    );
  }

  int _countOpenTodos(Project project) {
    return TodoRepository.getByProject(project.id)
        .where((todo) => !todo.isDone)
        .length;
  }

  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return DesignTokens.priorityLow;
      case TodoPriority.medium:
        return DesignTokens.priorityMedium;
      case TodoPriority.high:
        return DesignTokens.priorityHigh;
      case TodoPriority.urgent:
        return DesignTokens.priorityUrgent;
    }
  }

  Color _projectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return DesignTokens.infoColor;
      case ProjectStatus.active:
        return DesignTokens.primaryColor;
      case ProjectStatus.onHold:
        return DesignTokens.warningColor;
      case ProjectStatus.completed:
        return DesignTokens.successColor;
      case ProjectStatus.cancelled:
        return DesignTokens.errorColor;
      case ProjectStatus.archived:
        return DesignTokens.textSecondaryLight;
    }
  }

  Color _parseHexColor(String? value) {
    if (value == null || value.isEmpty) return DesignTokens.primaryColor;
    final normalized = value.replaceFirst('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.parse(hex, radix: 16));
  }
}
