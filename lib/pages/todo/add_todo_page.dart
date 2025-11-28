import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/services/calendar_sync_service.dart';
import 'package:praxis/common/widgets/praxis_text_field.dart';
import 'package:praxis/common/widgets/praxis_button.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/style/design_tokens.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  DateTime? _dueDate;
  TodoPriority _priority = TodoPriority.medium;
  bool _isLoading = false;
  List<String> _tags = [];
  String? _selectedProjectId;
  String? _selectedGoalId;
  List<Project> _projects = [];
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadProjectsAndGoals();
  }

  void _loadProjectsAndGoals() {
    setState(() {
      _projects = DatabaseService.getAllProjects();
      _goals = DatabaseService.getAllGoals();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _selectProject() async {
    if (_projects.isEmpty) {
      ErrorService.showWarning('暂无可用项目');
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDark
                : Colors.white,
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
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  child: Column(
                    children: [
                      Text(
                        '选择项目',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeHeadlineSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      ..._projects.map((project) {
                        final isSelected = _selectedProjectId == project.id;
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _parseColor(project.color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                            ),
                            child: Icon(
                              Icons.folder,
                              color: _parseColor(project.color),
                              size: 20,
                            ),
                          ),
                          title: Text(project.name),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: DesignTokens.primaryColor,
                                )
                              : null,
                          onTap: () {
                            Get.back(result: project.id);
                          },
                        );
                      }).toList(),
                      if (_selectedProjectId != null)
                        ListTile(
                          leading: const Icon(Icons.clear),
                          title: const Text('清除选择'),
                          onTap: () {
                            Get.back(result: '');
                          },
                        ),
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
        _selectedProjectId = selected.isEmpty ? null : selected;
      });
    }
  }

  Future<void> _selectGoal() async {
    if (_goals.isEmpty) {
      ErrorService.showWarning('暂无可用目标');
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDark
                : Colors.white,
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
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  child: Column(
                    children: [
                      Text(
                        '选择目标',
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
                              color: DesignTokens.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                            ),
                            child: Icon(
                              Icons.flag,
                              color: DesignTokens.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(goal.title),
                          subtitle: Text('${(goal.progress * 100).toStringAsFixed(0)}% 完成'),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: DesignTokens.primaryColor,
                                )
                              : null,
                          onTap: () {
                            Get.back(result: goal.id);
                          },
                        );
                      }).toList(),
                      if (_selectedGoalId != null)
                        ListTile(
                          leading: const Icon(Icons.clear),
                          title: const Text('清除选择'),
                          onTap: () {
                            Get.back(result: '');
                          },
                        ),
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
        _selectedGoalId = selected.isEmpty ? null : selected;
      });
    }
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    }
    return DesignTokens.primaryColor;
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final todo = Todo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        tags: _tags.isEmpty ? null : _tags,
        projectId: _selectedProjectId,
        goalId: _selectedGoalId,
      );

      await DatabaseService.addTodo(todo);
      
      // 同步到日历（如果启用）
      if (todo.dueDate != null) {
        await CalendarSyncService.syncTodo(todo);
      }
      
      if (mounted) {
        Get.back(result: true);
        ErrorService.showSuccess('待办事项已创建');
      }
    } catch (e) {
      LoggerService.error('创建待办事项失败', 'AddTodoPage', e);
      if (mounted) {
        ErrorService.handleError(e, context: '创建待办事项');
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
        title: const Text('添加待办事项'),
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
                    label: '标题',
                    hint: '请输入待办事项标题',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入标题';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  PraxisTextField(
                    controller: _descriptionController,
                    label: '描述（可选）',
                    hint: '请输入详细描述',
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  DropdownButtonFormField<TodoPriority>(
                    value: _priority,
                    decoration: InputDecoration(
                      labelText: '优先级',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing4,
                        vertical: DesignTokens.spacing4,
                      ),
                    ),
                    items: TodoPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  InkWell(
                    onTap: _selectDueDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '截止日期（可选）',
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
                            _dueDate == null
                                ? '未设置'
                                : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
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
            
            // 标签管理
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '标签',
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
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: '输入标签并按回车',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spacing4,
                              vertical: DesignTokens.spacing3,
                            ),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing3),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing3),
                    Wrap(
                      spacing: DesignTokens.spacing2,
                      runSpacing: DesignTokens.spacing2,
                      children: _tags.map((tag) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        return GestureDetector(
                          onTap: () => _removeTag(tag),
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
                                  tag,
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
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 关联项目
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关联项目',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  InkWell(
                    onTap: _selectProject,
                    child: Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? DesignTokens.borderDark
                              : DesignTokens.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder,
                                color: _selectedProjectId != null
                                    ? _parseColor(_projects.firstWhere((p) => p.id == _selectedProjectId).color)
                                    : (isDark
                                        ? DesignTokens.textSecondaryDark
                                        : DesignTokens.textSecondaryLight),
                              ),
                              const SizedBox(width: DesignTokens.spacing3),
                              Text(
                                _selectedProjectId != null
                                    ? _projects.firstWhere((p) => p.id == _selectedProjectId).name
                                    : '选择项目（可选）',
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeBodySmall,
                                  color: _selectedProjectId != null
                                      ? (isDark
                                          ? DesignTokens.onSurfaceDark
                                          : DesignTokens.onSurfaceLight)
                                      : (isDark
                                          ? DesignTokens.textSecondaryDark
                                          : DesignTokens.textSecondaryLight),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? DesignTokens.textTertiaryDark
                                : DesignTokens.textTertiaryLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 关联目标
            PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关联目标',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  InkWell(
                    onTap: _selectGoal,
                    child: Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? DesignTokens.borderDark
                              : DesignTokens.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag,
                                color: _selectedGoalId != null
                                    ? DesignTokens.primaryColor
                                    : (isDark
                                        ? DesignTokens.textSecondaryDark
                                        : DesignTokens.textSecondaryLight),
                              ),
                              const SizedBox(width: DesignTokens.spacing3),
                              Text(
                                _selectedGoalId != null
                                    ? _goals.firstWhere((g) => g.id == _selectedGoalId).title
                                    : '选择目标（可选）',
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeBodySmall,
                                  color: _selectedGoalId != null
                                      ? (isDark
                                          ? DesignTokens.onSurfaceDark
                                          : DesignTokens.onSurfaceLight)
                                      : (isDark
                                          ? DesignTokens.textSecondaryDark
                                          : DesignTokens.textSecondaryLight),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? DesignTokens.textTertiaryDark
                                : DesignTokens.textTertiaryLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: DesignTokens.spacing8),
            
            PraxisButton(
              text: '保存待办事项',
              onPressed: _isLoading ? null : _saveTodo,
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
