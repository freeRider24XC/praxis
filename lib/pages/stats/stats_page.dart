import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/settings/settings_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsTimeRange _timeRange = StatsTimeRange.week;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.to(() => const SettingsPage()),
            tooltip: '设置',
          ),
          PopupMenuButton<StatsTimeRange>(
            initialValue: _timeRange,
            onSelected: (range) {
              setState(() {
                _timeRange = range;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: StatsTimeRange.day,
                child: Text('今日'),
              ),
              const PopupMenuItem(
                value: StatsTimeRange.week,
                child: Text('本周'),
              ),
              const PopupMenuItem(
                value: StatsTimeRange.month,
                child: Text('本月'),
              ),
              const PopupMenuItem(
                value: StatsTimeRange.year,
                child: Text('本年'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewCards(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // Todo Completion Chart
            _buildSectionTitle('任务完成趋势'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildTodoCompletionChart(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // Goal Progress
            _buildSectionTitle('目标进度'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildGoalProgressCards(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // Project Status
            _buildSectionTitle('项目状态分布'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildProjectStatusChart(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // Productivity Score
            _buildSectionTitle('生产力评分'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildProductivityScore(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final todos = DatabaseService.getAllTodos();
    final goals = DatabaseService.getAllGoals();
    final projects = DatabaseService.getAllProjects();
    
    final todayTodos = todos.where((t) => t.isDueToday).length;
    final completedTodos = todos.where((t) => t.isDone).length;
    final activeGoals = goals.where((g) => g.status == GoalStatus.inProgress).length;
    final activeProjects = projects.where((p) => p.status == ProjectStatus.active).length;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: DesignTokens.spacing3,
      mainAxisSpacing: DesignTokens.spacing3,
      children: [
        _buildStatCard(
          title: '今日待办',
          value: todayTodos.toString(),
          icon: Icons.today,
          color: DesignTokens.primaryColor,
        ),
        _buildStatCard(
          title: '已完成',
          value: completedTodos.toString(),
          icon: Icons.check_circle,
          color: DesignTokens.successColor,
        ),
        _buildStatCard(
          title: '活跃目标',
          value: activeGoals.toString(),
          icon: Icons.flag,
          color: DesignTokens.warningColor,
        ),
        _buildStatCard(
          title: '进行项目',
          value: activeProjects.toString(),
          icon: Icons.folder_open,
          color: DesignTokens.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return PraxisCard(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTodoCompletionChart() {
    return PraxisCard(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final days = ['一', '二', '三', '四', '五', '六', '日'];
                    if (value.toInt() < days.length) {
                      return Text(days[value.toInt()]);
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3),
                  const FlSpot(1, 5),
                  const FlSpot(2, 4),
                  const FlSpot(3, 7),
                  const FlSpot(4, 6),
                  const FlSpot(5, 8),
                  const FlSpot(6, 5),
                ],
                isCurved: true,
                color: DesignTokens.primaryColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: DesignTokens.primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalProgressCards() {
    final goals = DatabaseService.getActiveGoals();
    
    if (goals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              '暂无进行中的目标',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: goals.take(3).map((goal) => PraxisCard(
        margin: const EdgeInsets.only(bottom: DesignTokens.spacing2),
        child: ListTile(
          title: Text(goal.title),
          subtitle: LinearProgressIndicator(
            value: goal.progress,
            backgroundColor: Colors.grey[300],
            minHeight: 4,
          ),
          trailing: Text(
            '${(goal.progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildProjectStatusChart() {
    final projects = DatabaseService.getAllProjects();
    final statusCounts = <ProjectStatus, int>{};
    
    for (var project in projects) {
      statusCounts[project.status] = (statusCounts[project.status] ?? 0) + 1;
    }
    
    if (statusCounts.isEmpty) {
      return PraxisCard(
        padding: const EdgeInsets.all(DesignTokens.spacing8),
        child: Center(
          child: Text(
            '暂无项目数据',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    return PraxisCard(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: statusCounts.entries.map((entry) {
                final total = statusCounts.values.reduce((a, b) => a + b);
                final percentage = (entry.value / total) * 100;
                
                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  title: '${percentage.toStringAsFixed(0)}%',
                  color: _getProjectStatusColor(entry.key),
                  radius: 80,
                );
              }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildProductivityScore() {
    final score = _calculateProductivityScore();
    final theme = Theme.of(context);
    
    return PraxisCard(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                  Text(
                    _getScoreLabel(score),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing6),
          Text(
            '基于任务完成率、目标进度和项目健康度计算',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateProductivityScore() {
    final todos = DatabaseService.getAllTodos();
    final goals = DatabaseService.getAllGoals();
    final projects = DatabaseService.getAllProjects();
    
    double todoScore = 0;
    if (todos.isNotEmpty) {
      final completed = todos.where((t) => t.isDone).length;
      todoScore = (completed / todos.length) * 100;
    }
    
    double goalScore = 0;
    if (goals.isNotEmpty) {
      final totalProgress = goals.fold(0.0, (sum, g) => sum + g.progress);
      goalScore = (totalProgress / goals.length) * 100;
    }
    
    double projectScore = 0;
    if (projects.isNotEmpty) {
      final healthyProjects = projects.where((p) => p.health == ProjectHealth.good).length;
      projectScore = (healthyProjects / projects.length) * 100;
    }
    
    // Weighted average
    return (todoScore * 0.4 + goalScore * 0.3 + projectScore * 0.3);
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return DesignTokens.successColor;
    if (score >= 60) return DesignTokens.primaryColor;
    if (score >= 40) return DesignTokens.warningColor;
    return DesignTokens.errorColor;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return '优秀';
    if (score >= 60) return '良好';
    if (score >= 40) return '一般';
    return '需要改进';
  }

  Color _getProjectStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.grey;
      case ProjectStatus.active:
        return DesignTokens.statusActive;
      case ProjectStatus.onHold:
        return DesignTokens.statusPaused;
      case ProjectStatus.completed:
        return DesignTokens.statusCompleted;
      case ProjectStatus.cancelled:
        return DesignTokens.statusCancelled;
      case ProjectStatus.archived:
        return Colors.brown;
    }
  }
}

enum StatsTimeRange {
  day,
  week,
  month,
  year,
}