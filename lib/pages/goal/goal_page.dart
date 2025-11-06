import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/widgets/empty_state.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/style/design_tokens.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
            // Tab selection handled by TabController
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
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curveEaseOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildGoalCard(goal),
        );
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: DesignTokens.durationNormal,
      curve: DesignTokens.curveDefault,
      builder: (context, animatedProgress, child) {
        return PraxisCard(
          margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
          onTap: () => _showGoalDetail(goal),
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Title Row
              Row(
                children: [
                  // Status text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(goal.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                    child: Text(
                      goal.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(goal.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              
              const SizedBox(height: DesignTokens.spacing3),
              
              // Title
              Text(
                goal.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Description
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacing2),
                Text(
                  goal.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: DesignTokens.spacing4),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: animatedProgress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(animatedProgress),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                ],
              ),
              
              const SizedBox(height: DesignTokens.spacing3),
              
              // Footer info
              Row(
                children: [
                  // Goal type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                    ),
                    child: Text(
                      goal.type.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Time remaining
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: isOverdue ? DesignTokens.errorColor : theme.disabledColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue 
                          ? '已逾期${-daysRemaining}天'
                          : daysRemaining > 0
                            ? '剩余$daysRemaining天'
                            : '今天截止',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue ? DesignTokens.errorColor : theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(GoalType? type) {
    String message;
    String? description;
    if (type == null) {
      message = '还没有设定任何目标';
      description = '设定目标，让每一天都有方向';
    } else {
      message = '还没有${type.displayName}';
      description = '开始创建你的第一个${type.displayName}吧';
    }

    return EmptyState(
      icon: Icons.flag_outlined,
      title: message,
      description: description,
      actionLabel: '创建目标',
      onAction: () => Get.toNamed('/goal/add'),
    );
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