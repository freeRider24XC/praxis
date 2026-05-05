import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/empty_state.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/pages/goal/add_goal_page.dart';
import 'package:praxis/pages/goal/goal_detail_page.dart';
import 'package:praxis/pages/life_domains/domain_detail_page.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  LifeDomain? _focusedDomain;
  List<Goal> _focusedDomainGoals = const [];
  List<Goal> _activeGoals = const [];
  List<Goal> _completedGoals = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  void _load() {
    final focusedDomain = DomainService.getFocusedDomain();
    final allGoals = DatabaseService.getAllGoals();

    final activeGoals = allGoals
        .where((goal) => goal.status != GoalStatus.completed)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
    final completedGoals = allGoals
        .where((goal) => goal.status == GoalStatus.completed)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final focusedDomainGoals = focusedDomain == null
        ? <Goal>[]
        : DatabaseService.getGoalsByDomain(focusedDomain.id).toList()
          ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

    if (!mounted) return;
    setState(() {
      _focusedDomain = focusedDomain;
      _focusedDomainGoals = focusedDomainGoals;
      _activeGoals = activeGoals;
      _completedGoals = completedGoals;
    });
  }

  Future<void> _createGoal() async {
    await Get.to(
      () => AddGoalPage(initialDomainId: _focusedDomain?.id),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => _load(),
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
              _buildFocusedGoalSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildActiveGoalsSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildCompletedGoalsSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final focusedLabel = _focusedDomain == null
        ? '还没有设置当前重点领域'
        : '围绕 ${_focusedDomain!.icon} ${_focusedDomain!.name} 推进';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '目标',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeHeadlineSmall,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing2),
              Text(
                focusedLabel,
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.spacing4),
        FilledButton.icon(
          onPressed: _createGoal,
          icon: const Icon(Icons.add),
          label: const Text('新目标'),
        ),
      ],
    );
  }

  Widget _buildFocusedGoalSection(bool isDark) {
    final focusedDomain = _focusedDomain;
    final highlightedGoal = _focusedDomainGoals.isEmpty
        ? null
        : _focusedDomainGoals.firstWhere(
            (goal) => goal.status == GoalStatus.inProgress,
            orElse: () => _focusedDomainGoals.first,
          );

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: highlightedGoal == null
          ? EmptyState(
              icon: Icons.flag_outlined,
              title: focusedDomain == null ? '还没有重点领域' : '重点领域还没有目标',
              description: focusedDomain == null
                  ? '先去选择一个当前重点方向，再围绕它建立目标。'
                  : '先为这个领域创建一个正在推进的目标。',
              actionLabel: focusedDomain == null ? '查看领域' : '创建目标',
              onAction: () async {
                if (focusedDomain == null) {
                  return;
                }
                await Get.to(
                  () => DomainDetailPage(domainId: focusedDomain.id),
                );
                _load();
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前最该盯住的目标',
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
                  focusedDomain == null
                      ? '把最重要的一个方向推进到底。'
                      : '来自 ${focusedDomain.icon} ${focusedDomain.name}',
                  style: DesignTokens.textStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing4),
                _buildHighlightedGoalCard(highlightedGoal, isDark),
              ],
            ),
    );
  }

  Widget _buildActiveGoalsSection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      title: '进行中的目标',
      subtitle: '把注意力放在正在推进的事情上。',
      goals: _activeGoals,
      emptyTitle: '还没有进行中的目标',
      emptyDescription: '先创建一个近期会持续推进的目标。',
    );
  }

  Widget _buildCompletedGoalsSection(bool isDark) {
    return _buildSection(
      isDark: isDark,
      title: '最近完成',
      subtitle: '这些已经成为你的累计进展。',
      goals: _completedGoals.take(5).toList(),
      emptyTitle: '还没有完成的目标',
      emptyDescription: '完成第一个目标后，这里会开始记录你的节奏。',
      completed: true,
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required String subtitle,
    required List<Goal> goals,
    required String emptyTitle,
    required String emptyDescription,
    bool completed = false,
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
          Text(
            title,
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
            subtitle,
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing4),
          if (goals.isEmpty)
            EmptyState(
              icon: completed ? Icons.emoji_events_outlined : Icons.flag_outlined,
              title: emptyTitle,
              description: emptyDescription,
              actionLabel: completed ? '去推进目标' : '创建目标',
              onAction: _createGoal,
            )
          else
            ...goals.map((goal) => _buildGoalCard(goal, isDark)),
        ],
      ),
    );
  }

  Widget _buildHighlightedGoalCard(Goal goal, bool isDark) {
    final domain = DomainService.getDomainById(goal.domainId);
    final progress = goal.progress.clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return PraxisCard(
      onTap: () async {
        await Get.to(() => GoalDetailPage(goalId: goal.id));
        _load();
      },
      padding: const EdgeInsets.all(DesignTokens.spacing5),
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
                  color: _getStatusColor(goal.status).withValues(alpha: 0.12),
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
              const Spacer(),
              if (domain != null)
                Text(
                  '${domain.icon} ${domain.name}',
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
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: isDark
                ? DesignTokens.surfaceDarkSecondary
                : DesignTokens.surfaceLightSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              Text(
                '$percent% 完成',
                style: DesignTokens.textStyle(
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
              const Spacer(),
              Text(
                _buildDeadlineLabel(goal),
                style: DesignTokens.textStyle(
                  color: goal.isOverdue
                      ? DesignTokens.errorColor
                      : (isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, bool isDark) {
    final domain = DomainService.getDomainById(goal.domainId);
    return PraxisCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      onTap: () async {
        await Get.to(() => GoalDetailPage(goalId: goal.id));
        _load();
      },
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing2,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(goal.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Text(
                  goal.status.displayName,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    color: _getStatusColor(goal.status),
                    fontWeight: DesignTokens.fontWeightBold,
                  ),
                ),
              ),
              const Spacer(),
              if (domain != null)
                Text(
                  '${domain.icon} ${domain.name}',
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
          Text(
            goal.title,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeBodyLarge,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DesignTokens.textStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.spacing4),
          LinearProgressIndicator(
            value: goal.progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: isDark
                ? DesignTokens.surfaceDarkSecondary
                : DesignTokens.surfaceLightSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(goal.progress),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              Text(
                goal.type.displayName,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  color: DesignTokens.primaryColor,
                  fontWeight: DesignTokens.fontWeightBold,
                ),
              ),
              const Spacer(),
              Text(
                _buildDeadlineLabel(goal),
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  color: goal.isOverdue
                      ? DesignTokens.errorColor
                      : (isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildDeadlineLabel(Goal goal) {
    if (goal.status == GoalStatus.completed) {
      return '已完成';
    }
    if (goal.isOverdue) {
      return '已逾期${-goal.daysRemaining}天';
    }
    if (goal.daysRemaining > 0) {
      return '剩余${goal.daysRemaining}天';
    }
    return '今天截止';
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

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return DesignTokens.successColor;
    if (progress >= 0.5) return DesignTokens.primaryColor;
    if (progress >= 0.3) return DesignTokens.warningColor;
    return DesignTokens.errorColor;
  }
}
