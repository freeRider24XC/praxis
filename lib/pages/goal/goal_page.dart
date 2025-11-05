import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoalType _selectedType = GoalType.yearly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目标管理'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '年度'),
            Tab(text: '季度'),
            Tab(text: '月度'),
            Tab(text: '周目标'),
            Tab(text: '全部'),
          ],
          onTap: (index) {
            setState(() {
              if (index < 4) {
                _selectedType = GoalType.values[index];
              }
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showGoalAnalytics(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGoalList(GoalType.yearly),
          _buildGoalList(GoalType.quarterly),
          _buildGoalList(GoalType.monthly),
          _buildGoalList(GoalType.weekly),
          _buildAllGoals(),
        ],
      ),
    );
  }

  Widget _buildGoalList(GoalType type) {
    final goals = DatabaseService.getGoalsByType(type);

    if (goals.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(goal);
      },
    );
  }

  Widget _buildAllGoals() {
    final goals = DatabaseService.getAllGoals();
    
    if (goals.isEmpty) {
      return _buildEmptyState(null);
    }

    // Group goals by status
    final activeGoals = goals.where((g) => g.status == GoalStatus.inProgress).toList();
    final completedGoals = goals.where((g) => g.status == GoalStatus.completed).toList();
    final otherGoals = goals.where((g) => 
      g.status != GoalStatus.inProgress && g.status != GoalStatus.completed
    ).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeGoals.isNotEmpty) ...[
          _buildSectionHeader('进行中', Colors.blue),
          ...activeGoals.map((goal) => _buildGoalCard(goal)),
          const SizedBox(height: 16),
        ],
        if (otherGoals.isNotEmpty) ...[
          _buildSectionHeader('待开始', Colors.orange),
          ...otherGoals.map((goal) => _buildGoalCard(goal)),
          const SizedBox(height: 16),
        ],
        if (completedGoals.isNotEmpty) ...[
          _buildSectionHeader('已完成', Colors.green),
          ...completedGoals.map((goal) => _buildGoalCard(goal)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final theme = Theme.of(context);
    final progress = goal.progress;
    final isOverdue = goal.isOverdue;
    final daysRemaining = goal.daysRemaining;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showGoalDetail(goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(goal.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Title
                  Expanded(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.type.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (goal.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '进度',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(progress),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                    minHeight: 8,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Footer info
              Row(
                children: [
                  // Time remaining
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue ? Colors.red : theme.disabledColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOverdue 
                      ? '已逾期${-daysRemaining}天'
                      : daysRemaining > 0
                        ? '剩余$daysRemaining天'
                        : '今天截止',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOverdue ? Colors.red : theme.disabledColor,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Key results count
                  if (goal.keyResults != null && goal.keyResults!.isNotEmpty) ...[
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.keyResults!.where((kr) => kr.isCompleted).length}/${goal.keyResults!.length} KR',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                  
                  // Linked todos count
                  if (goal.linkedTodoIds != null && goal.linkedTodoIds!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.checklist,
                      size: 16,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.linkedTodoIds!.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(GoalType? type) {
    String message;
    if (type == null) {
      message = '还没有设定任何目标';
    } else {
      message = '还没有${type.displayName}';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/goal/add'),
            icon: const Icon(Icons.add),
            label: const Text('创建目标'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.notStarted:
        return Colors.grey;
      case GoalStatus.inProgress:
        return Colors.blue;
      case GoalStatus.paused:
        return Colors.orange;
      case GoalStatus.completed:
        return Colors.green;
      case GoalStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.3) return Colors.orange;
    return Colors.red;
  }

  void _showGoalDetail(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                const Text(
                  '描述',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(goal.description!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Text(
                    '类型: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(goal.type.displayName),
                    backgroundColor: Colors.purple.shade100,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '目标日期: ${_formatDate(goal.targetDate)}',
              ),
              const SizedBox(height: 8),
              Text(
                '状态: ${goal.status.displayName}',
              ),
              const SizedBox(height: 8),
              Text(
                '进度: ${(goal.progress * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showGoalAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目标分析'),
        content: const Text('目标分析功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}