import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zx/common/models/index.dart';
import 'package:zx/common/services/database_service.dart';
import 'package:zx/common/widgets/zx_widgets.dart';
import 'package:zx/common/style/design_tokens.dart';
import 'package:zx/pages/settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StatsTimeRange _timeRange = StatsTimeRange.week;
  String _userName = '张三';
  String _userBio = '高效工作,优质生活';
  String? _userAvatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 个人信息区域
            _buildProfileHeader(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 数据概览卡片
            _buildSectionTitle('数据概览'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildOverviewCards(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 统计分析卡片
            _buildSectionTitle('统计分析'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildStatsSection(),
            
            const SizedBox(height: DesignTokens.spacing6),
            
            // 设置区域
            _buildSectionTitle('设置'),
            const SizedBox(height: DesignTokens.spacing3),
            _buildSettingsSection(),
            
            const SizedBox(height: DesignTokens.spacing6),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ZxCard(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: Row(
        children: [
          // 头像
          GestureDetector(
            onTap: _editProfile,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
              backgroundImage: _userAvatar != null ? NetworkImage(_userAvatar!) : null,
              child: _userAvatar == null
                  ? Text(
                      _userName.isNotEmpty ? _userName[0] : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.primaryColor,
                      ),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: DesignTokens.spacing4),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _userName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: _editProfile,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing1),
                Text(
                  _userBio,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
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

  Widget _buildOverviewCards() {
    final todos = DatabaseService.getAllTodos();
    final goals = DatabaseService.getAllGoals();
    final projects = DatabaseService.getAllProjects();
    
    final totalTodos = todos.length;
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
          title: '待办总数',
          value: totalTodos.toString(),
          icon: Icons.check_circle_outline,
          color: DesignTokens.primaryColor,
        ),
        _buildStatCard(
          title: '已完成',
          value: completedTodos.toString(),
          icon: Icons.check_circle,
          color: DesignTokens.successColor,
        ),
        _buildStatCard(
          title: '进行中目标',
          value: activeGoals.toString(),
          icon: Icons.flag,
          color: DesignTokens.warningColor,
        ),
        _buildStatCard(
          title: '活跃项目',
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
    
    return ZxCard(
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

  Widget _buildStatsSection() {
    return ZxCard(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间范围选择
          Row(
            children: [
              Expanded(
                child: Text(
                  '统计分析',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<StatsTimeRange>(
                initialValue: _timeRange,
                onSelected: (range) {
                  setState(() {
                    _timeRange = range;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing3,
                    vertical: DesignTokens.spacing2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getTimeRangeText(_timeRange)),
                      const SizedBox(width: DesignTokens.spacing1),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
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
          
          const SizedBox(height: DesignTokens.spacing4),
          
          // 任务完成趋势图
          Text(
            '任务完成趋势',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          SizedBox(
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
          
          const SizedBox(height: DesignTokens.spacing6),
          
          // 目标进度卡片
          Text(
            '目标进度',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          _buildGoalProgressCards(),
          
          const SizedBox(height: DesignTokens.spacing6),
          
          // 项目状态分布图
          Text(
            '项目状态分布',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          SizedBox(
            height: 200,
            child: _buildProjectStatusChart(),
          ),
          
          const SizedBox(height: DesignTokens.spacing6),
          
          // 生产力评分
          Text(
            '生产力评分',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          _buildProductivityScore(),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCards() {
    final goals = DatabaseService.getActiveGoals();
    
    if (goals.isEmpty) {
      return ZxCard(
        padding: const EdgeInsets.all(DesignTokens.spacing8),
        child: Center(
          child: Text(
            '暂无进行中的目标',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    return Column(
      children: goals.take(3).map((goal) => ZxCard(
        margin: const EdgeInsets.only(bottom: DesignTokens.spacing2),
        padding: const EdgeInsets.all(DesignTokens.spacing3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[300],
                    minHeight: 4,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing3),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
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
      return ZxCard(
        padding: const EdgeInsets.all(DesignTokens.spacing8),
        child: Center(
          child: Text(
            '暂无项目数据',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    return PieChart(
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
    );
  }

  Widget _buildProductivityScore() {
    final score = _calculateProductivityScore();
    final theme = Theme.of(context);
    
    return ZxCard(
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

  Widget _buildSettingsSection() {
    return Column(
      children: [
        ZxCard(
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('应用设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.to(() => const SettingsPage()),
          ),
        ),
      ],
    );
  }

  void _editProfile() {
    // TODO: 实现编辑个人信息功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑个人信息'),
        content: const Text('编辑个人信息功能正在开发中'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _getTimeRangeText(StatsTimeRange range) {
    switch (range) {
      case StatsTimeRange.day:
        return '今日';
      case StatsTimeRange.week:
        return '最近7天';
      case StatsTimeRange.month:
        return '本月';
      case StatsTimeRange.year:
        return '本年';
    }
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

