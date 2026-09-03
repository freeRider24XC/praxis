import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/repositories/index.dart';
import 'package:praxis/common/services/domain_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/widgets/praxis_text_field.dart';
import 'package:praxis/common/widgets/praxis_button.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/style/design_tokens.dart';

class AddProjectPage extends StatefulWidget {
  final String? initialDomainId;
  final String? initialGoalId;

  const AddProjectPage({
    super.key,
    this.initialDomainId,
    this.initialGoalId,
  });

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _endDate;
  ProjectStatus _status = ProjectStatus.planning;
  String _color = '#2196F3';
  bool _isLoading = false;
  String? _selectedDomainId;
  String? _selectedGoalId;
  List<Goal> _goals = [];

  final List<Color> _colorOptions = [
    DesignTokens.primaryColor,
    DesignTokens.successColor,
    DesignTokens.warningColor,
    const Color(0xFF9C27B0), // Purple
    DesignTokens.errorColor,
    DesignTokens.secondaryColor,
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _goals = GoalRepository.getAll();
    _selectedGoalId = widget.initialGoalId;
    _selectedDomainId =
        widget.initialDomainId ?? _goalDomainId(widget.initialGoalId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  String? _goalDomainId(String? goalId) {
    if (goalId == null) return null;
    return GoalRepository.getById(goalId)?.domainId;
  }

  Future<void> _selectGoal() async {
    if (_goals.isEmpty) {
      ErrorService.showWarning('请先创建目标');
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: DesignTokens.spacing3),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.borderDark
                        : DesignTokens.borderLight,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  child: Column(
                    children: [
                      Text(
                        '归属目标',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeHeadlineSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      ..._goals.map((goal) {
                        final isSelected = _selectedGoalId == goal.id;
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: DesignTokens.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusLarge,
                              ),
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: DesignTokens.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(goal.title),
                          subtitle: goal.description?.isNotEmpty == true
                              ? Text(
                                  goal.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: DesignTokens.primaryColor,
                                )
                              : null,
                          onTap: () => Get.back(result: goal.id),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedGoalId = selected;
        _selectedDomainId = _goalDomainId(selected) ?? _selectedDomainId;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGoalId == null) {
      ErrorService.showWarning('项目必须归属一个目标');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final project = Project(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _status,
        color: _color,
        endDate: _endDate,
        goalIds: [_selectedGoalId!],
        domainId: _selectedDomainId,
      );

      await ProjectRepository.add(project);
      await GoalRepository.setProjectLinks(_selectedGoalId!, [project.id]);

      if (mounted) {
        Get.back(result: true);
        ErrorService.showSuccess('项目已创建');
      }
    } catch (e) {
      LoggerService.error('创建项目失败', 'AddProjectPage', e);
      if (mounted) {
        ErrorService.handleError(e, context: '创建项目');
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
    final domains = DomainService.getDomains();
    final selectedGoal = _selectedGoalId == null
        ? null
        : GoalRepository.getById(_selectedGoalId!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建项目'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          children: [
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PraxisTextField(
                    controller: _nameController,
                    label: '项目名称',
                    hint: '请输入项目名称',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入项目名称';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  PraxisTextField(
                    controller: _descriptionController,
                    label: '描述（可选）',
                    hint: '请输入项目描述',
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  DropdownButtonFormField<ProjectStatus>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: '状态',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing4,
                        vertical: DesignTokens.spacing4,
                      ),
                    ),
                    items: ProjectStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  InkWell(
                    onTap: _selectGoal,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '归属目标',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusLarge),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing4,
                          vertical: DesignTokens.spacing4,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedGoal?.title ?? '请选择一个目标',
                              style: TextStyle(
                                color: selectedGoal == null
                                    ? Theme.of(context).hintColor
                                    : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  DropdownButtonFormField<String?>(
                    value: _selectedDomainId,
                    decoration: InputDecoration(
                      labelText: '所属领域',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing4,
                        vertical: DesignTokens.spacing4,
                      ),
                    ),
                    items: [
                      ...domains.map((domain) {
                        return DropdownMenuItem<String?>(
                          value: domain.id,
                          child: Text('${domain.icon} ${domain.name}'),
                        );
                      }),
                    ],
                    onChanged: selectedGoal != null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedDomainId = value;
                            });
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing4),
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '项目颜色',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: DesignTokens.fontWeightMedium,
                        ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _colorOptions.map((color) {
                      final isSelected = _color == _colorToHex(color);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _color = _colorToHex(color);
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.spacing4),
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing4),
              child: InkWell(
                onTap: _selectEndDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '结束日期（可选）',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLarge),
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
                        _endDate == null
                            ? '未设置'
                            : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            PraxisButton(
              text: '保存项目',
              onPressed: _isLoading ? null : _saveProject,
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
