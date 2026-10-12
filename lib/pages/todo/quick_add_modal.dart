import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/tag_chip.dart';
import 'package:praxis/common/repositories/index.dart';
import 'package:praxis/common/services/calendar_sync_service.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:get/get.dart';

/// 快捷任务弹窗
class QuickAddModal extends StatefulWidget {
  const QuickAddModal({super.key});

  @override
  State<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<QuickAddModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isToday = false;
  bool _isHighPriority = false;
  bool _useAiPolish = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      return;
    }

    final todo = Todo(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: _isToday ? DateTime.now() : null,
      priority: _isHighPriority ? TodoPriority.high : TodoPriority.medium,
    );

    await TodoRepository.add(todo);

    // 同步到日历（如果启用）
    if (todo.dueDate != null) {
      await CalendarSyncService.syncTodo(todo);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXLarge + 8),
          topRight: Radius.circular(DesignTokens.radiusXLarge + 8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: DesignTokens.spacing3),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color:
                    isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
                borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacing8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '新建任务',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeHeadlineSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.surfaceDarkSecondary
                                : DesignTokens.surfaceLightSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: isDark
                                ? DesignTokens.textSecondaryDark
                                : DesignTokens.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacing6),

                  // 输入框
                  TextField(
                    controller: _titleController,
                    style: DesignTokens.textStyle(
                      fontSize: 24,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                    decoration: InputDecoration(
                      hintText: '准备做什么？',
                      hintStyle: DesignTokens.textStyle(
                        fontSize: 24,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: isDark
                            ? DesignTokens.textTertiaryDark
                            : DesignTokens.textTertiaryLight,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: DesignTokens.spacing4),

                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodySmall,
                      fontWeight: DesignTokens.fontWeightMedium,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                    decoration: InputDecoration(
                      hintText: '添加描述、备注或子任务...',
                      hintStyle: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodySmall,
                        color: isDark
                            ? DesignTokens.textTertiaryDark
                            : DesignTokens.textTertiaryLight,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: DesignTokens.spacing6),

                  // 快捷标签
                  Wrap(
                    spacing: DesignTokens.spacing3,
                    runSpacing: DesignTokens.spacing3,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _isToday = !_isToday);
                        },
                        child: TagChip(
                          label: '今天',
                          icon: Icons.calendar_today,
                          style: _isToday
                              ? TagChipStyle.primary
                              : TagChipStyle.neutral,
                          isSelected: _isToday,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isHighPriority = !_isHighPriority);
                        },
                        child: TagChip(
                          label: '高优先级',
                          icon: Icons.flag,
                          style: _isHighPriority
                              ? TagChipStyle.warning
                              : TagChipStyle.neutral,
                          isSelected: _isHighPriority,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _useAiPolish = !_useAiPolish);
                        },
                        child: TagChip(
                          label: 'AI 润色',
                          icon: Icons.auto_awesome,
                          style: _useAiPolish
                              ? TagChipStyle.secondary
                              : TagChipStyle.neutral,
                          isSelected: _useAiPolish,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacing8),

                  // 创建按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: DesignTokens.spacing4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusXLarge),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 18),
                          const SizedBox(width: DesignTokens.spacing2),
                          Text(
                            '创建任务',
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeBodyMedium,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
