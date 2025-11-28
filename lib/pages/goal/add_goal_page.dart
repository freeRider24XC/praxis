import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/widgets/praxis_text_field.dart';
import 'package:praxis/common/widgets/praxis_button.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/style/design_tokens.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _milestoneController = TextEditingController();
  final _krTitleController = TextEditingController();
  final _krTargetController = TextEditingController();
  final _krUnitController = TextEditingController();
  
  DateTime? _targetDate;
  GoalType _type = GoalType.monthly;
  bool _isLoading = false;
  List<String> _milestones = [];
  List<KeyResult> _keyResults = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _milestoneController.dispose();
    _krTitleController.dispose();
    _krTargetController.dispose();
    _krUnitController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _addMilestone() {
    final milestone = _milestoneController.text.trim();
    if (milestone.isNotEmpty && !_milestones.contains(milestone)) {
      setState(() {
        _milestones.add(milestone);
        _milestoneController.clear();
      });
    }
  }

  void _removeMilestone(String milestone) {
    setState(() {
      _milestones.remove(milestone);
    });
  }

  void _addKeyResult() {
    final title = _krTitleController.text.trim();
    if (title.isEmpty) {
      ErrorService.showWarning('请输入关键结果标题');
      return;
    }

    final targetValue = _krTargetController.text.trim();
    final unit = _krUnitController.text.trim();

    setState(() {
      _keyResults.add(KeyResult(
        title: title,
        targetValue: targetValue.isNotEmpty ? int.tryParse(targetValue) : null,
        currentValue: 0,
        unit: unit.isEmpty ? null : unit,
      ));
      _krTitleController.clear();
      _krTargetController.clear();
      _krUnitController.clear();
    });
  }

  void _removeKeyResult(KeyResult kr) {
    setState(() {
      _keyResults.remove(kr);
    });
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final goal = Goal(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _type,
        targetDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
        milestones: _milestones.isEmpty ? null : _milestones,
        keyResults: _keyResults.isEmpty ? null : _keyResults,
      );

      await DatabaseService.addGoal(goal);
      
      if (mounted) {
        Get.back(result: true);
        ErrorService.showSuccess('目标已创建');
      }
    } catch (e) {
      LoggerService.error('创建目标失败', 'AddGoalPage', e);
      if (mounted) {
        ErrorService.handleError(e, context: '创建目标');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      appBar: AppBar(
        title: const Text('创建目标'),
        backgroundColor: isDark
            ? DesignTokens.backgroundDark
            : Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spacing6),
          children: [
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PraxisTextField(
                    controller: _titleController,
                    label: '目标标题',
                    hint: '请输入目标标题',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入目标标题';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  PraxisTextField(
                    controller: _descriptionController,
                    label: '描述（可选）',
                    hint: '请输入目标描述',
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  DropdownButtonFormField<GoalType>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: '目标类型',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing4,
                        vertical: DesignTokens.spacing4,
                      ),
                    ),
                    items: GoalType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _type = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  InkWell(
                    onTap: _selectTargetDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '目标日期',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing4,
                          vertical: DesignTokens.spacing4,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _targetDate == null
                                ? '未设置'
                                : '${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 关键结果管理
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关键结果 (Key Results)',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  PraxisTextField(
                    controller: _krTitleController,
                    label: '关键结果标题',
                    hint: '例如：完成10个功能模块',
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  Row(
                    children: [
                      Expanded(
                        child: PraxisTextField(
                          controller: _krTargetController,
                          label: '目标值（可选）',
                          hint: '例如：10',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing3),
                      Expanded(
                        child: PraxisTextField(
                          controller: _krUnitController,
                          label: '单位（可选）',
                          hint: '例如：个',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  PraxisButton(
                    text: '添加关键结果',
                    onPressed: _addKeyResult,
                    type: PraxisButtonType.outline,
                    size: PraxisButtonSize.medium,
                    isFullWidth: true,
                  ),
                  if (_keyResults.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing4),
                    ..._keyResults.map((kr) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
                        padding: const EdgeInsets.all(DesignTokens.spacing4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? DesignTokens.surfaceDarkSecondary
                              : DesignTokens.surfaceLightSecondary,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                          border: Border.all(
                            color: isDark
                                ? DesignTokens.borderDark
                                : DesignTokens.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kr.title,
                                    style: DesignTokens.textStyle(
                                      fontSize: DesignTokens.fontSizeBodySmall,
                                      fontWeight: DesignTokens.fontWeightBold,
                                      color: isDark
                                          ? DesignTokens.onSurfaceDark
                                          : DesignTokens.onSurfaceLight,
                                    ),
                                  ),
                                  if (kr.targetValue != null) ...[
                                    const SizedBox(height: DesignTokens.spacing1),
                                    Text(
                                      '目标: ${kr.targetValue}${kr.unit ?? ''}',
                                      style: DesignTokens.textStyle(
                                        fontSize: DesignTokens.fontSizeLabelSmall,
                                        color: isDark
                                            ? DesignTokens.textSecondaryDark
                                            : DesignTokens.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _removeKeyResult(kr),
                              iconSize: 18,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 里程碑管理
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '里程碑',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _milestoneController,
                          decoration: InputDecoration(
                            hintText: '输入里程碑并按回车',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spacing4,
                              vertical: DesignTokens.spacing3,
                            ),
                          ),
                          onSubmitted: (_) => _addMilestone(),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing3),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addMilestone,
                      ),
                    ],
                  ),
                  if (_milestones.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing3),
                    Wrap(
                      spacing: DesignTokens.spacing2,
                      runSpacing: DesignTokens.spacing2,
                      children: _milestones.map((milestone) {
                        return GestureDetector(
                          onTap: () => _removeMilestone(milestone),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spacing3,
                              vertical: DesignTokens.spacing2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? DesignTokens.surfaceDarkSecondary
                                  : DesignTokens.surfaceLightSecondary,
                              borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                              border: Border.all(
                                color: isDark
                                    ? DesignTokens.borderDark
                                    : DesignTokens.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  milestone,
                                  style: DesignTokens.textStyle(
                                    fontSize: DesignTokens.fontSizeLabelSmall,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: isDark
                                        ? DesignTokens.onSurfaceDark
                                        : DesignTokens.onSurfaceLight,
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.spacing1),
                                Icon(
                                  Icons.close,
                                  size: 14,
                                  color: isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.spacing8),
            
            PraxisButton(
              text: '保存目标',
              onPressed: _isLoading ? null : _saveGoal,
              type: PraxisButtonType.primary,
              size: PraxisButtonSize.large,
              isFullWidth: true,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
