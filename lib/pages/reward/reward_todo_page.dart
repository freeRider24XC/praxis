import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/i18n/app_strings.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class RewardTodoPage extends StatefulWidget {
  const RewardTodoPage({super.key});

  @override
  State<RewardTodoPage> createState() => _RewardTodoPageState();
}

class _RewardTodoPageState extends State<RewardTodoPage> {
  Map<RewardTodoStatus, List<RewardTodo>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _grouped = RewardService.getTodosByStatus();
  }

  bool _isExpired(RewardTodo todo) {
    final due = todo.dueDate;
    if (due == null) return false;
    return DateTime.now().isAfter(due);
  }

  Future<void> _markComplete(RewardTodo todo) async {
    await RewardService.completeRewardTodo(todo);
    if (!mounted) return;
    setState(_refresh);
    Get.snackbar(
      todo.title,
      AppStrings.rewardTodoCompleteSuccess.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pending = _grouped[RewardTodoStatus.pending] ?? [];
    final completed = _grouped[RewardTodoStatus.completed] ?? [];
    final total = pending.length + completed.length +
        (_grouped[RewardTodoStatus.expired]?.length ?? 0);

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.rewardTodoTitle.tr),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing4,
              vertical: DesignTokens.spacing2,
            ),
            child: Center(
              child: Text(
                AppStrings.rewardTodoCount.trNamed({
                  'done': completed.length.toString(),
                  'total': total.toString(),
                }),
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
      body: total == 0
          ? _buildEmptyHint(isDark)
          : ListView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              children: _buildSections(isDark),
            ),
    );
  }

  List<Widget> _buildSections(bool isDark) {
    final widgets = <Widget>[];

    final pending = _grouped[RewardTodoStatus.pending] ?? [];
    final expired = _grouped[RewardTodoStatus.expired] ?? [];
    final completed = _grouped[RewardTodoStatus.completed] ?? [];

    final pendingActive = [
      ...pending,
      ...expired,
    ];

    if (pendingActive.isNotEmpty) {
      widgets.add(_buildSectionHeader(
        label: AppStrings.rewardTodoGroupPending.tr,
        color: DesignTokens.statusActive,
        isDark: isDark,
      ));
      for (final todo in pendingActive) {
        widgets.add(_buildTodoCard(
          todo: todo,
          isDark: isDark,
          actionable: true,
          isOverdue: _isExpired(todo),
        ));
      }
    }

    if (completed.isNotEmpty) {
      widgets.add(_buildSectionHeader(
        label: AppStrings.rewardTodoGroupCompleted.tr,
        color: DesignTokens.statusCompleted,
        isDark: isDark,
      ));
      for (final todo in completed) {
        widgets.add(_buildTodoCard(
          todo: todo,
          isDark: isDark,
          actionable: false,
        ));
      }
    }

    return widgets;
  }

  Widget _buildSectionHeader({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: DesignTokens.spacing3,
        top: DesignTokens.spacing4,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: DesignTokens.spacing2),
          Text(
            label,
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

  Widget _buildTodoCard({
    required RewardTodo todo,
    required bool isDark,
    required bool actionable,
    bool isOverdue = false,
  }) {
    final isCompleted = todo.status == RewardTodoStatus.completed;
    final dateLabel = todo.dueDate != null
        ? AppStrings.rewardTodoDueLabel
            .trNamed({'date': _formatDate(todo.dueDate!)})
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isOverdue && actionable
              ? DesignTokens.warningColor.withOpacity(0.5)
              : (isDark ? DesignTokens.borderDark : DesignTokens.borderLight),
          width: isOverdue && actionable ? 1.0 : 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: actionable ? () => _markComplete(todo) : null,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? DesignTokens.statusCompleted
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? DesignTokens.statusCompleted
                      : (isOverdue && actionable
                          ? DesignTokens.warningColor
                          : (isDark
                              ? DesignTokens.borderDark
                              : DesignTokens.borderLight)),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: DesignTokens.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyMedium,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isCompleted
                        ? (isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight)
                        : (isDark
                            ? DesignTokens.onSurfaceDark
                            : DesignTokens.onSurfaceLight),
                  ).copyWith(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (dateLabel != null) ...[
                  const SizedBox(height: DesignTokens.spacing1),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: isOverdue && actionable
                            ? DesignTokens.warningColor
                            : (isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateLabel,
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeLabelSmall,
                          color: isOverdue && actionable
                              ? DesignTokens.warningColor
                              : (isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight),
                          fontWeight: isOverdue && actionable
                              ? DesignTokens.fontWeightBold
                              : DesignTokens.fontWeightRegular,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (actionable)
            TextButton(
              onPressed: () => _markComplete(todo),
              style: TextButton.styleFrom(
                foregroundColor: DesignTokens.statusCompleted,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing3,
                  vertical: DesignTokens.spacing1,
                ),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(AppStrings.rewardTodoCompleteAction.tr),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        child: Text(
          AppStrings.rewardTodoEmptyHint.tr,
          textAlign: TextAlign.center,
          style: DesignTokens.textStyle(
            color: isDark
                ? DesignTokens.textSecondaryDark
                : DesignTokens.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
