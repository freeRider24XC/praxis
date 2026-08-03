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
  bool _showTodoDrafts = false;
  String? _confirmedDomainId;

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
      _confirmedDomainId = draft.domainId;
      _showTodoDrafts = false;
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
      _showTodoDrafts = false;
    });
  }

  bool _canConfirm(AiGoalPlanDraft draft) {
    if (draft.goal.title.trim().isEmpty) return false;
    if (draft.project.name.trim().isEmpty) return false;
    if (draft.todos.isEmpty) return false;
    return !draft.todos.any((todo) => todo.title.trim().isEmpty);
  }

  void _normalizeDraft(AiGoalPlanDraft draft) {
    draft.goal.title = draft.goal.title.trim();
    draft.goal.description = draft.goal.description?.trim();
    if (draft.goal.description?.isEmpty ?? false) {
      draft.goal.description = null;
    }

    draft.project.name = draft.project.name.trim();
    draft.project.description = draft.project.description?.trim();
    if (draft.project.description?.isEmpty ?? false) {
      draft.project.description = null;
    }

    draft.milestones.replaceRange(
      0,
      draft.milestones.length,
      draft.milestones.map((item) => item.trim()).where((item) => item.isNotEmpty),
    );

    draft.todos
      ..removeWhere((todo) => todo.title.trim().isEmpty)
      ..replaceRange(
        0,
        draft.todos.length,
        draft.todos.map((todo) {
          todo.title = todo.title.trim();
          todo.description = todo.description?.trim();
          if (todo.description?.isEmpty ?? false) {
            todo.description = null;
          }
          return todo;
        }),
      );
  }

  Future<void> _confirmPlan() async {
    final draft = _draft;
    if (draft == null) return;

    _normalizeDraft(draft);
    if (!_canConfirm(draft)) {
      Get.snackbar('还不能创建', '请先确认目标、项目和至少一条事项都已填写完整。');
      return;
    }

    final confirmedDomainId = _confirmedDomainId ?? draft.domainId;
    draft.goal.domainId = confirmedDomainId;
    draft.project.domainId = confirmedDomainId;
    draft.goal.milestones = draft.milestones.isEmpty ? null : draft.milestones;
    await DatabaseService.addGoal(draft.goal);

    draft.project.goalIds = [draft.goal.id];
    await DatabaseService.addProject(draft.project);

    draft.goal.projectIds = [draft.project.id];
    await DatabaseService.updateGoal(draft.goal);

    final todos = draft.todos
        .map((todo) => todo.copyWith(
              projectId: draft.project.id,
              domainId: confirmedDomainId,
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

  Future<void> _editGoalDraft(AiGoalPlanDraft draft) async {
    final titleController = TextEditingController(text: draft.goal.title);
    final descriptionController =
        TextEditingController(text: draft.goal.description ?? '');
    await _showEditorSheet(
      title: '编辑目标草稿',
      builder: (isDark) => [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: '目标标题'),
        ),
        const SizedBox(height: DesignTokens.spacing3),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '目标描述'),
        ),
      ],
      onSave: () {
        setState(() {
          draft.goal.title = titleController.text.trim();
          draft.goal.description = descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim();
        });
      },
    );
  }

  Future<void> _editProjectDraft(AiGoalPlanDraft draft) async {
    final titleController = TextEditingController(text: draft.project.name);
    final descriptionController =
        TextEditingController(text: draft.project.description ?? '');
    await _showEditorSheet(
      title: '编辑项目草稿',
      builder: (isDark) => [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: '项目名称'),
        ),
        const SizedBox(height: DesignTokens.spacing3),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '项目描述'),
        ),
      ],
      onSave: () {
        setState(() {
          draft.project.name = titleController.text.trim();
          draft.project.description = descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim();
        });
      },
    );
  }

  Future<void> _editMilestone(AiGoalPlanDraft draft, int index) async {
    final controller = TextEditingController(text: draft.milestones[index]);
    await _showEditorSheet(
      title: '编辑里程碑',
      builder: (isDark) => [
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(labelText: '里程碑内容'),
        ),
      ],
      onSave: () {
        final next = controller.text.trim();
        if (next.isEmpty) return;
        setState(() {
          draft.milestones[index] = next;
        });
      },
    );
  }

  Future<void> _addMilestone(AiGoalPlanDraft draft) async {
    final controller = TextEditingController();
    await _showEditorSheet(
      title: '新增里程碑',
      builder: (isDark) => [
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(labelText: '里程碑内容'),
        ),
      ],
      onSave: () {
        final next = controller.text.trim();
        if (next.isEmpty) return;
        setState(() {
          draft.milestones.add(next);
        });
      },
    );
  }

  void _removeMilestone(AiGoalPlanDraft draft, int index) {
    setState(() {
      draft.milestones.removeAt(index);
    });
  }

  Future<void> _editTodo(AiGoalPlanDraft draft, int index) async {
    final todo = draft.todos[index];
    final titleController = TextEditingController(text: todo.title);
    final descriptionController =
        TextEditingController(text: todo.description ?? '');
    var priority = todo.priority;
    await _showEditorSheet(
      title: '编辑事项草稿',
      builder: (isDark) => [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: '事项标题'),
        ),
        const SizedBox(height: DesignTokens.spacing3),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '事项描述'),
        ),
        const SizedBox(height: DesignTokens.spacing3),
        StatefulBuilder(
          builder: (context, setStateModal) {
            return DropdownButtonFormField<TodoPriority>(
              value: priority,
              items: TodoPriority.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setStateModal(() {
                  priority = value;
                });
              },
              decoration: const InputDecoration(labelText: '优先级'),
            );
          },
        ),
      ],
      onSave: () {
        setState(() {
          todo.title = titleController.text.trim();
          todo.description = descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim();
          todo.priority = priority;
        });
      },
    );
  }

  Future<void> _addTodo(AiGoalPlanDraft draft) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    var priority = TodoPriority.medium;
    await _showEditorSheet(
      title: '新增事项草稿',
      builder: (isDark) => [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: '事项标题'),
        ),
        const SizedBox(height: DesignTokens.spacing3),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '事项描述'),
        ),
        const SizedBox(height: DesignTokens.spacing3),
        StatefulBuilder(
          builder: (context, setStateModal) {
            return DropdownButtonFormField<TodoPriority>(
              value: priority,
              items: TodoPriority.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setStateModal(() {
                  priority = value;
                });
              },
              decoration: const InputDecoration(labelText: '优先级'),
            );
          },
        ),
      ],
      onSave: () {
        final title = titleController.text.trim();
        if (title.isEmpty) return;
        setState(() {
          draft.todos.add(
            Todo(
              title: title,
              description: descriptionController.text.trim().isEmpty
                  ? null
                  : descriptionController.text.trim(),
              priority: priority,
              domainId: _confirmedDomainId ?? draft.domainId,
            ),
          );
        });
      },
    );
  }

  void _removeTodo(AiGoalPlanDraft draft, int index) {
    setState(() {
      draft.todos.removeAt(index);
    });
  }

  Future<void> _showEditorSheet({
    required String title,
    required List<Widget> Function(bool isDark) builder,
    required VoidCallback onSave,
  }) async {
    await showModalBottomSheet<void>(
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
                    title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleLarge,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  ...builder(isDark),
                  const SizedBox(height: DesignTokens.spacing4),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onSave();
                        Get.back();
                      },
                      child: const Text('保存修改'),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final draft = _draft;

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
                  title: '阶段 1 · 当前主线',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '先说最近最想拉起来什么，系统会先帮你形成目标和推进项目，再拆事项。',
                        style: DesignTokens.textStyle(
                          color: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing3),
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
                          child: const Text('生成目标与项目草稿'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (draft != null) ...[
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '阶段 2 · 归属领域确认',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '系统先推断到这个领域，你可以在确认前调整。',
                          style: DesignTokens.textStyle(
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spacing3),
                        DropdownButtonFormField<String>(
                          value: _confirmedDomainId ?? draft.domainId,
                          items: DomainService.getDomains()
                              .map(
                                (domain) => DropdownMenuItem(
                                  value: domain.id,
                                  child: Text('${domain.icon} ${domain.name}'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _confirmedDomainId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '阶段 3 · 目标草稿',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          label: '目标草稿可以继续改',
                          actionLabel: '编辑',
                          onTap: () => _editGoalDraft(draft),
                        ),
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
                    title: '阶段 4 · 当前推进项目',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          label: '先把项目命名和定位调顺',
                          actionLabel: '编辑',
                          onTap: () => _editProjectDraft(draft),
                        ),
                        Text(
                          draft.project.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if ((draft.project.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: DesignTokens.spacing2),
                          Text(draft.project.description!),
                        ],
                        const SizedBox(height: DesignTokens.spacing3),
                        Text(
                          '后续事项会先挂在这个项目下，再由项目把推进结果汇入目标。',
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
                  const SizedBox(height: DesignTokens.spacing4),
                  _buildCard(
                    isDark: isDark,
                    title: '阶段 5 · 里程碑草稿',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          label: '这些里程碑决定项目大致怎么推进',
                          actionLabel: '新增',
                          onTap: () => _addMilestone(draft),
                        ),
                        if (draft.milestones.isEmpty)
                          Text(
                            '还没有里程碑，先补 1 到 3 个阶段节点。',
                            style: DesignTokens.textStyle(
                              color: isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight,
                            ),
                          )
                        else
                          ...draft.milestones.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.flag_outlined),
                              title: Text(item),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    onPressed: () => _editMilestone(draft, index),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeMilestone(draft, index),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  if (draft.followUpQuestions.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing4),
                    _buildCard(
                      isDark: isDark,
                      title: '确认前最好再想清楚',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: draft.followUpQuestions
                            .map((question) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: DesignTokens.spacing2,
                                  ),
                                  child: Text('• $question'),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: DesignTokens.spacing4),
                  if (!_showTodoDrafts)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showTodoDrafts = true;
                        });
                      },
                      child: const Text('目标和项目没问题了，再看事项草稿'),
                    ),
                  if (_showTodoDrafts) ...[
                    const SizedBox(height: DesignTokens.spacing4),
                    _buildCard(
                      isDark: isDark,
                      title: '阶段 6 · 事项草稿',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            label: '这些事项都会创建到当前推进项目下',
                            actionLabel: '新增',
                            onTap: () => _addTodo(draft),
                          ),
                          Text(
                            '你可以先改标题、描述和优先级，再决定要不要创建。',
                            style: DesignTokens.textStyle(
                              color: isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing3),
                          if (draft.todos.isEmpty)
                            Text(
                              '还没有事项草稿，至少补一条最小下一步。',
                              style: DesignTokens.textStyle(
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            )
                          else
                            ...draft.todos.asMap().entries.map((entry) {
                              final index = entry.key;
                              final todo = entry.value;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading:
                                    const Icon(Icons.check_circle_outline),
                                title: Text(todo.title),
                                subtitle: todo.description == null
                                    ? null
                                    : Text(todo.description!),
                                trailing: Wrap(
                                  spacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(todo.priority.displayName),
                                    ),
                                    IconButton(
                                      onPressed: () => _editTodo(draft, index),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeTodo(draft, index),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing6),
                    ElevatedButton(
                      onPressed: _canConfirm(draft) ? _confirmPlan : null,
                      child: Text(
                        draft.isMock ? '确认创建这条推进链（Mock）' : '确认创建这条推进链',
                      ),
                    ),
                  ],
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

  Widget _buildSectionHeader({
    required String label,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          TextButton(
            onPressed: onTap,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
