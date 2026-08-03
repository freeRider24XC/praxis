import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/repositories/repository_provider.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/goal/goal_detail_page.dart';
import 'package:praxis/pages/goal/goal_page.dart';
import 'package:praxis/pages/project/add_project_page.dart';
import 'package:praxis/pages/project/project_detail_page.dart';
import 'package:praxis/pages/rewards/reward_center_page.dart';
import 'package:praxis/pages/rewards/reward_todos_page.dart';
import 'package:praxis/pages/review/daily_review_page.dart';
import 'package:praxis/pages/schedule/schedule_page.dart';
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
  List<TodoScheduleSlot> _todaySchedule = [];
  List<RewardTodo> _pendingRewardTodos = [];
  int _praisePoints = 0;

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

  Future<void> _loadData() async {
    final repository = RepositoryProvider.instance;
    await repository.refreshWeeklySchedule();

    final profile = repository.getProfile();
    final goals = repository.getGoals();
    final projects = repository.getProjects();
    final xpEvents = repository.getRecentXpEvents(limit: 4);
    final review = repository.getDailyReviewByDate(DateTime.now());
    final todaySchedule = repository.getTodaySchedule();
    final pendingRewardTodos = repository.getPendingRewardTodos();
    final praisePoints = repository.getPraisePointsBalance();

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
          .where((project) =>
              DatabaseService.getProjectPrimaryGoalId(project) == currentGoal!.id)
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
        ? DatabaseService.getTodosByProject(currentProject.id)
            .where((todo) => !todo.isDone)
            .toList()
        : repository.getRecommendedTodosForToday(limit: 5);

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
      _todaySchedule = todaySchedule;
      _pendingRewardTodos = pendingRewardTodos;
      _praisePoints = praisePoints;
    });
  }

  Future<void> _toggleTodo(Todo todo) async {
    await RepositoryProvider.instance.toggleTodo(todo);
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
              _buildDecisionBoard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildNextActionStrip(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildScheduleCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildReviewCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildRewardsCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildGrowthSnapshot(isDark, profile),
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
                _currentGoal == null
                    ? '先定当前主目标，再拆出项目和事项'
                    : _currentProject == null
                        ? '先把主目标压成一个推进项目'
                        : '今天只决定这一个项目先推进哪一步',
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
        Row(
          children: [
            _buildHeaderAction(
              isDark: isDark,
              icon: Icons.calendar_today,
              label: '排程',
              onTap: () => Get.to(() => const SchedulePage()),
            ),
            const SizedBox(width: DesignTokens.spacing2),
            _buildHeaderAction(
              isDark: isDark,
              icon: Icons.history,
              label: '复盘',
              onTap: _openDailyReview,
              highlighted: true,
            ),
          ],
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
        ? null
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
            onPressed: action ??
                () async {
                  await Get.to(() => const GoalPage());
                  await _loadData();
                },
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
                  label: '犒赏点',
                  value: '$_praisePoints 点',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionBoard(bool isDark) {
    final goal = _currentGoal;
    final project = _currentProject;
    final leadTodo = _todayTodos.isEmpty ? null : _todayTodos.first;
    final hasLeadTodo = leadTodo != null;
    final focusedDomain = DomainService.getFocusedDomain();

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
            '今天的推进决策',
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
            hasLeadTodo
                ? '不要同时推进很多事，先把当前项目里的这一小步做掉。'
                : '先把主线压缩成一个项目，再把今天要做的一步定出来。',
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          _buildDecisionLayer(
            isDark: isDark,
            overline: '当前主目标',
            title: goal?.title ?? '还没有当前主目标',
            subtitle: goal == null
                ? '先确定这一阶段最想推进的结果。'
                : (goal.description?.isNotEmpty ?? false)
                    ? goal.description!
                    : '先抓住这阶段最重要的结果，不被别的事分散。',
            chipLabel: focusedDomain == null
                ? null
                : '${focusedDomain.icon} ${focusedDomain.name}',
            progress: goal?.progress,
            meta: goal == null
                ? null
                : '${goal.status.displayName} · 截止 ${goal.targetDate.month}/${goal.targetDate.day}',
            onTap: goal == null
                ? null
                : () async {
                    await Get.to(() => GoalDetailPage(goalId: goal.id));
                    await _loadData();
                  },
          ),
          const SizedBox(height: DesignTokens.spacing4),
          _buildDecisionLayer(
            isDark: isDark,
            overline: '当前推进项目',
            title: project?.name ?? '还没有推进项目',
            subtitle: project == null
                ? '把主目标拆成 1-3 个项目，再决定最近真正推进哪一块。'
                : (project.description?.isNotEmpty ?? false)
                    ? project.description!
                    : '项目是目标和事项之间的桥梁，先盯住这一块。',
            chipLabel: project?.status.displayName,
            chipColor: project == null ? null : _projectStatusColor(project.status),
            progress: project?.progress,
            meta: project == null
                ? null
                : '${_countOpenTodos(project)} 个待完成事项',
            onTap: project == null
                ? null
                : () async {
                    await Get.to(() => ProjectDetailPage(projectId: project.id));
                    await _loadData();
                  },
          ),
          const SizedBox(height: DesignTokens.spacing4),
          _buildLeadTodoCard(isDark, leadTodo),
          if (_todayTodos.length > 1) ...[
            const SizedBox(height: DesignTokens.spacing4),
            Text(
              '后续事项',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeLabelMedium,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2),
            ..._todayTodos.skip(1).take(2).map((todo) => Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spacing2),
                  child: Text(
                    '• ${todo.title}',
                    style: DesignTokens.textStyle(
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionLayer({
    required bool isDark,
    required String overline,
    required String title,
    required String subtitle,
    String? chipLabel,
    Color? chipColor,
    double? progress,
    String? meta,
    Future<void> Function()? onTap,
  }) {
    final content = Container(
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
          Row(
            children: [
              Text(
                overline,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
              const Spacer(),
              if (chipLabel != null)
                _buildStatusChip(
                  label: chipLabel,
                  color: chipColor ?? DesignTokens.primaryColor,
                  isDark: isDark,
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            title,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleMedium,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            subtitle,
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          if (progress != null && meta != null) ...[
            const SizedBox(height: DesignTokens.spacing3),
            _buildProgressBlock(
              isDark: isDark,
              progress: progress,
              meta: meta,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      child: content,
    );
  }

  Widget _buildLeadTodoCard(bool isDark, Todo? todo) {
    if (todo == null) {
      return _buildDecisionLayer(
        isDark: isDark,
        overline: '今天这一件事',
        title: '还没有今日事项',
        subtitle: '先给当前项目补一件可以在今天启动的明确动作。',
      );
    }

    final project = todo.projectId == null
        ? null
        : DatabaseService.getProjectById(todo.projectId!);

    return InkWell(
      onTap: () async {
        await Get.to(() => TodoDetailPage(todoId: todo.id));
        await _loadData();
      },
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        decoration: BoxDecoration(
          color: DesignTokens.primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          border: Border.all(
            color: DesignTokens.primaryColor.withValues(alpha: isDark ? 0.36 : 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '今天这一件事',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: DesignTokens.primaryColor,
                  ),
                ),
                const Spacer(),
                _buildStatusChip(
                  label: todo.priority.displayName,
                  color: _priorityColor(todo.priority),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              todo.title,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeHeadlineSmall,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
            if (todo.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: DesignTokens.spacing2),
              Text(
                todo.description!,
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
            const SizedBox(height: DesignTokens.spacing3),
            Wrap(
              spacing: DesignTokens.spacing2,
              runSpacing: DesignTokens.spacing2,
              children: [
                if (project != null)
                  _buildStatusChip(
                    label: project.name,
                    color: _parseHexColor(project.color),
                    isDark: isDark,
                  ),
                if (todo.dueDate != null)
                  _buildStatusChip(
                    label: '截止 ${todo.dueDate!.month}/${todo.dueDate!.day}',
                    color: DesignTokens.secondaryPurple,
                    isDark: isDark,
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spacing4),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleTodo(todo),
                    child: const Text('完成这一步'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing3),
                OutlinedButton(
                  onPressed: () async {
                    await Get.to(() => TodoDetailPage(todoId: todo.id));
                    await _loadData();
                  },
                  child: const Text('查看'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(bool isDark) {
    final hasSchedule = _todaySchedule.isNotEmpty;
    final projectName = _currentProject?.name;
    return _buildSectionCard(
      isDark: isDark,
      title: '本周编排',
      actionLabel: '查看日程',
      onActionTap: () => Get.to(() => const SchedulePage()),
      child: hasSchedule
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _todaySchedule.take(3).map((slot) {
                final todo = DatabaseService.getTodoById(slot.todoId);
                if (todo == null) {
                  return const SizedBox.shrink();
                }
                final start = slot.scheduledStart;
                final timeLabel = start == null
                    ? '今天安排'
                    : '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: DesignTokens.spacing3),
                  child: Text('• $timeLabel · ${todo.title}'),
                );
              }).toList(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName == null
                      ? '先定当前推进项目，再把它的事项排进本周节奏。'
                      : '先把“$projectName”要推进的动作排进生活，不然项目只会停在想法层。',
                  style: DesignTokens.textStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing4),
                ElevatedButton(
                  onPressed: () => Get.to(() => const SchedulePage()),
                  child: const Text('去安排本周计划'),
                ),
              ],
            ),
    );
  }

  Widget _buildRewardsCard(bool isDark) {
    final pendingCount = _pendingRewardTodos.length;
    final projectName = _currentProject?.name;
    return _buildSectionCard(
      isDark: isDark,
      title: '奖励兑现',
      actionLabel: '奖励中心',
      onActionTap: () => Get.to(() => const RewardCenterPage()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pendingCount == 0
                ? projectName == null
                    ? '先把当前项目推进起来，完成关键事项后再用 $_praisePoints 点犒赏点兑换真实奖励。'
                    : '把“$projectName”往前推时，你已经攒下 $_praisePoints 点犒赏点，可以换一次真实奖励。'
                : '有 $pendingCount 个奖励待办还没兑现，别让项目推进后的犒赏停留在概念层。',
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
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const RewardCenterPage()),
                  child: const Text('去兑换奖励'),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.to(() => const RewardTodosPage()),
                  child: const Text('奖励待办'),
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

  Widget _buildReviewCard(bool isDark) {
    final completed = _todayReview?.isCompleted ?? false;
    final projectName = _currentProject?.name;
    return _buildSectionCard(
      isDark: isDark,
      title: '今日复盘',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            completed
                ? '今天的复盘已经完成，明天继续推进的重点已经接出来了。'
                : projectName == null
                    ? '睡前花一分钟，总结今天，并确认明天先推进哪个项目。'
                    : '睡前花一分钟，确认“$projectName”今天推到了哪里，再顺出明天最重要的一步。',
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
    return DatabaseService.getTodosByProject(project.id)
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
