import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/review/daily_review_page.dart';
import 'package:praxis/pages/todo/todo_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserProfile? _profile;
  LifeDomain? _focusedDomain;
  List<Todo> _todayTodos = [];
  List<XpEvent> _xpEvents = [];
  String _todaySuggestion = '';
  bool _isSuggestionMock = true;
  double _weeklyProgress = 0;

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
    final profile = ProfileService.getProfile();
    final focusedDomain = DomainService.getFocusedDomain();
    final todayTodos = DatabaseService.getTopTodosForToday(limit: 3);
    final xpEvents = DatabaseService.getAllXpEvents().take(5).toList();
    final suggestion = await AiUseCaseService().suggestTodayPlan();
    final weeklyProgress = ProfileService.getFocusedDomainWeeklyProgress();

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _focusedDomain = focusedDomain;
      _todayTodos = todayTodos;
      _xpEvents = xpEvents;
      _todaySuggestion = suggestion.content;
      _isSuggestionMock = suggestion.isMock;
      _weeklyProgress = weeklyProgress;
    });
  }

  Future<void> _toggleTodo(Todo todo) async {
    final wasDone = todo.isDone;
    todo.toggleDone();
    await DatabaseService.updateTodo(todo);
    if (!wasDone && todo.isDone) {
      await XpService.awardTodoCompleted(todo);
    }
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
    final levelProgress = XpService.xpIntoCurrentLevel(profile.totalXp);
    final levelMax = XpService.xpNeededWithinCurrentLevel(profile.totalXp);

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
              _buildLevelCard(isDark, profile, levelProgress, levelMax),
              const SizedBox(height: DesignTokens.spacing5),
              _buildFocusedDomainCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildSuggestionCard(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildTodayTodoSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildXpFeedSection(isDark),
              const SizedBox(height: DesignTokens.spacing5),
              _buildReviewEntry(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    bool isDark,
    UserProfile profile,
    int levelProgress,
    int levelMax,
  ) {
    final progress =
        levelMax == 0 ? 0.0 : (levelProgress / levelMax).clamp(0.0, 1.0);
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
          Text(
            '今日仪表盘',
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
            'Lv.${profile.level} 继续推进',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeHeadlineSmall,
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
              minHeight: 12,
              backgroundColor: isDark
                  ? DesignTokens.surfaceDarkSecondary
                  : DesignTokens.surfaceLightSecondary,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  DesignTokens.primaryColor),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${profile.totalXp} XP',
                style: DesignTokens.textStyle(
                  fontWeight: DesignTokens.fontWeightBold,
                  color: DesignTokens.primaryColor,
                ),
              ),
              Text(
                '连续 ${profile.streakDays} 天',
                style: DesignTokens.textStyle(
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusedDomainCard(bool isDark) {
    final domain = _focusedDomain;
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前重点领域',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          Row(
            children: [
              Text(
                domain?.icon ?? '🎯',
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: DesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain?.name ?? '尚未选择',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeTitleLarge,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing1),
                    Text(
                      '本周进度 ${(100 * _weeklyProgress).round()}%',
                      style: DesignTokens.textStyle(
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
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.primaryColor,
            DesignTokens.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 今日建议',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing2,
              vertical: DesignTokens.spacing1,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
            ),
            child: Text(
              _isSuggestionMock ? 'Mock 模式' : 'Live 模式',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeLabelSmall,
                fontWeight: DesignTokens.fontWeightBold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Text(
            _todaySuggestion,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeBodyLarge,
              fontWeight: DesignTokens.fontWeightMedium,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTodoSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '今天最重要的 3 件事',
      child: _todayTodos.isEmpty
          ? Text(
              '今天还没有待推进的任务，先去生成你的第一周计划吧。',
              style: DesignTokens.textStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            )
          : Column(
              children: _todayTodos.map((todo) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => _toggleTodo(todo),
                  ),
                  title: Text(todo.title),
                  subtitle: todo.dueDate == null
                      ? null
                      : Text(
                          '${todo.dueDate!.month.toString().padLeft(2, '0')}-${todo.dueDate!.day.toString().padLeft(2, '0')}',
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Get.to(() => TodoDetailPage(todoId: todo.id));
                    await _loadData();
                  },
                );
              }).toList(),
            ),
    );
  }

  Widget _buildXpFeedSection(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '最近反馈',
      child: _xpEvents.isEmpty
          ? Text(
              '完成一次任务后，这里会出现你的成长记录。',
              style: DesignTokens.textStyle(
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            )
          : Column(
              children: _xpEvents.map((event) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
                    child: Text(
                      '+${event.xp}',
                      style: const TextStyle(
                        color: DesignTokens.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(event.description),
                  subtitle: Text(
                    '${event.createdAt.month}-${event.createdAt.day} ${event.createdAt.hour.toString().padLeft(2, '0')}:${event.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildReviewEntry(bool isDark) {
    return _buildSectionCard(
      isDark: isDark,
      title: '每日复盘',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '睡前花一分钟，记录今天的推进和明天最重要的一步。',
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
              onPressed: () async {
                await Get.to(() => const DailyReviewPage());
                await _loadData();
              },
              child: const Text('去完成今日复盘'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
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
          const SizedBox(height: DesignTokens.spacing3),
          child,
        ],
      ),
    );
  }
}
