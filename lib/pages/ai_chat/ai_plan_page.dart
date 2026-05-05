import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class AiPlanPage extends StatefulWidget {
  final String initialGoalText;

  const AiPlanPage({
    super.key,
    required this.initialGoalText,
  });

  @override
  State<AiPlanPage> createState() => _AiPlanPageState();
}

class _AiPlanPageState extends State<AiPlanPage> {
  late final TextEditingController _goalController;
  AiGoalPlanDraft? _draft;
  String? _draftGoalText;
  bool _isLoading = false;
  AiPlanAvailability? _availability;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController(text: widget.initialGoalText);
    _loadAvailability();
    if (widget.initialGoalText.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generatePlan();
      });
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    final availability = await AiUseCaseService().getAvailability();
    if (!mounted) return;
    setState(() {
      _availability = availability;
    });
  }

  Future<void> _generatePlan() async {
    final goalText = _goalController.text.trim();
    if (goalText.isEmpty) return;

    final profile = ProfileService.getProfile();
    final focusedDomainId =
        profile.focusedDomainId ?? DatabaseService.getAllLifeDomains().first.id;

    setState(() {
      _isLoading = true;
    });

    final draft = await AiUseCaseService().planGoal(
      goalText: goalText,
      focusedDomainId: focusedDomainId,
      weeklyCapacityHours: profile.weeklyCapacityHours,
    );

    if (!mounted) return;
    setState(() {
      _draft = draft;
      _draftGoalText = goalText;
      _isLoading = false;
    });
  }

  void _handleGoalChanged(String value) {
    final nextGoalText = value.trim();
    if (_draft == null) return;
    if (_draftGoalText == nextGoalText) return;
    setState(() {
      _draft = null;
      _draftGoalText = null;
    });
  }

  Future<void> _confirmPlan() async {
    final draft = _draft;
    if (draft == null) return;

    draft.goal.milestones = draft.milestones;
    await DatabaseService.addGoal(draft.goal);

    draft.project.goalIds = [draft.goal.id];
    await DatabaseService.addProject(draft.project);

    draft.goal.projectIds = [draft.project.id];
    await DatabaseService.updateGoal(draft.goal);

    final todos = draft.todos
        .map((todo) => todo.copyWith(
              goalId: draft.goal.id,
              projectId: draft.project.id,
              domainId: draft.domainId,
            ))
        .toList();
    await DatabaseService.addTodos(todos);

    draft.project.todoIds = todos.map((todo) => todo.id).toList();
    await DatabaseService.updateProject(draft.project);
    await DatabaseService.recalculateProjectProgress(draft.project.id);
    await DatabaseService.recalculateGoalProgress(draft.goal.id);

    if (!mounted) return;
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = _draft;
    final focusedDomain =
        draft == null ? null : DomainService.getDomainById(draft.domainId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 规划'),
      ),
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              children: [
                if (_availability != null) ...[
                  _buildCard(
                    isDark: isDark,
                    title: 'AI 状态',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _availability!.isConfigured
                              ? '当前使用 ${_availability!.providerLabel} 在线生成'
                              : '当前未配置模型，使用本地 Mock 规划兜底',
                        ),
                        const SizedBox(height: DesignTokens.spacing2),
                        Text(
                          _availability!.isConfigured
                              ? '如果在线调用失败，也会自动回退到 Mock，保证流程可继续。'
                              : '你仍然可以完整演示闭环；配置 API 后，界面行为保持一致，只是数据来源会切到 live。',
                          style: DesignTokens.textStyle(
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                ],
                _buildCard(
                  isDark: isDark,
                  title: '你的目标',
                  child: Column(
                    children: [
                      TextField(
                        controller: _goalController,
                        maxLines: 3,
                        onChanged: _handleGoalChanged,
                        decoration: InputDecoration(
                          hintText: '例如：三个月内建立稳定健身习惯',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusLarge),
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing3),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _generatePlan,
                          child: const Text('生成这周计划'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (draft != null) ...[
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '归属领域',
                    child: Text(
                        '${focusedDomain?.icon ?? '🎯'} ${focusedDomain?.name ?? '未识别'}'),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '目标',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.goal.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if ((draft.goal.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: DesignTokens.spacing2),
                          Text(draft.goal.description!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '里程碑',
                    child: Column(
                      children: draft.milestones
                          .map((item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.flag_outlined),
                                title: Text(item),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '本周任务',
                    child: Column(
                      children: draft.todos
                          .map((todo) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.check_circle_outline),
                                title: Text(todo.title),
                                subtitle: todo.description == null
                                    ? null
                                    : Text(todo.description!),
                                trailing: Text(todo.priority.displayName),
                              ))
                          .toList(),
                    ),
                  ),
                  if (draft.followUpQuestions.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing4),
                    _buildCard(
                      isDark: isDark,
                      title: '建议先想清楚',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: draft.followUpQuestions
                            .map((question) => Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: DesignTokens.spacing2),
                                  child: Text('• $question'),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: DesignTokens.spacing6),
                  ElevatedButton(
                    onPressed: _confirmPlan,
                    child: Text(draft.isMock ? '确认创建（Mock 方案）' : '确认创建'),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildCard({
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
              fontSize: DesignTokens.fontSizeBodyLarge,
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
