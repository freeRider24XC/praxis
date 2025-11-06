import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/widgets/empty_state.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/i18n/app_strings.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  ProjectView _currentView = ProjectView.grid;
  ProjectStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.projectManagement.tr),
        actions: [
          IconButton(
            icon: Icon(_currentView == ProjectView.grid 
              ? Icons.list 
              : Icons.grid_view),
            onPressed: () {
              setState(() {
                _currentView = _currentView == ProjectView.grid
                  ? ProjectView.list
                  : ProjectView.grid;
              });
            },
            tooltip: _currentView == ProjectView.grid ? AppStrings.listView.tr : AppStrings.gridView.tr,
          ),
          PopupMenuButton<ProjectStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _statusFilter = status;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text(AppStrings.allProjects.tr),
              ),
              const PopupMenuDivider(),
              ...ProjectStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Text(_getStatusDisplayName(status)),
              )),
            ],
          ),
        ],
      ),
      body: _buildProjectView(),
    );
  }

  Widget _buildProjectView() {
    final projects = _getFilteredProjects();

    if (projects.isEmpty) {
      return _buildEmptyState();
    }

    if (_currentView == ProjectView.grid) {
      return _buildGridView(projects);
    } else {
      return _buildListView(projects);
    }
  }

  Widget _buildGridView(List<Project> projects) {
    return GridView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: DesignTokens.spacing3,
        mainAxisSpacing: DesignTokens.spacing3,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.curveEaseOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: _buildProjectGridCard(project),
        );
      },
    );
  }

  Widget _buildListView(List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
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
          child: _buildProjectListCard(project),
        );
      },
    );
  }

  Widget _buildProjectGridCard(Project project) {
    final theme = Theme.of(context);
    final color = _parseColor(project.color);

    return AnimatedSwitcher(
      duration: DesignTokens.durationNormal,
      child: PraxisCard(
        key: ValueKey(project.id),
        onTap: () => _showProjectDetail(project),
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProjectIcon(project.icon),
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Health indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getHealthColor(project.health),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              project.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.progressPercentage.trNamed({
                        'percentage': (project.progress * 100).toInt().toString()
                      }),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (project.daysRemaining > 0)
                      Text(
                        AppStrings.daysRemaining.trNamed({
                          'days': project.daysRemaining.toString()
                        }),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(project.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusDisplayName(project.status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(project.status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectListCard(Project project) {
    final theme = Theme.of(context);
    final color = _parseColor(project.color);

    return PraxisCard(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      onTap: () => _showProjectDetail(project),
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getProjectIcon(project.icon),
              color: color,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and health
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      project.health.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                
                if (project.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    project.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Progress bar
                LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
                
                const SizedBox(height: 8),
                
                // Meta info
                Row(
                  children: [
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(project.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusDisplayName(project.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(project.status),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Progress percentage
                    Text(
                      AppStrings.progressPercentage.trNamed({
                        'percentage': (project.progress * 100).toInt().toString()
                      }),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Tasks count
                    if (project.totalTasks > 0) ...[
                      Icon(
                        Icons.checklist,
                        size: 16,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.taskCount.trNamed({
                          'count': project.totalTasks.toString()
                        }),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                    
                    // Days remaining
                    if (project.daysRemaining > 0) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.daysRemaining.trNamed({
                          'days': project.daysRemaining.toString()
                        }),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final message = _statusFilter != null 
        ? AppStrings.noProjectsWithStatus.trNamed({
          'status': _getStatusDisplayName(_statusFilter!)
        })
        : AppStrings.notCreatedAnyProjects.tr;
    final description = _statusFilter != null 
      ? AppStrings.adjustFilter.tr : AppStrings.startCreatingProject.tr;
    
    return EmptyState(
      icon: Icons.folder_outlined,
      title: message,
      description: description,
      actionLabel: AppStrings.createProject.tr,
      onAction: () => Get.toNamed('/project/add'),
    );
  }

  List<Project> _getFilteredProjects() {
    var projects = DatabaseService.getAllProjects();
    
    if (_statusFilter != null) {
      projects = projects.where((p) => p.status == _statusFilter).toList();
    }
    
    // Sort by status and progress
    projects.sort((a, b) {
      if (a.status == ProjectStatus.active && b.status != ProjectStatus.active) {
        return -1;
      }
      if (a.status != ProjectStatus.active && b.status == ProjectStatus.active) {
        return 1;
      }
      return b.progress.compareTo(a.progress);
    });
    
    return projects;
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) | 0xFF000000);
    }
    return Colors.blue;
  }

  IconData _getProjectIcon(String? icon) {
    switch (icon) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'study':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      case 'finance':
        return Icons.attach_money;
      default:
        return Icons.folder;
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.grey;
      case ProjectStatus.active:
        return Colors.blue;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
      case ProjectStatus.archived:
        return Colors.grey;
    }
  }

  Color _getHealthColor(ProjectHealth health) {
    switch (health) {
      case ProjectHealth.good:
        return Colors.green;
      case ProjectHealth.atRisk:
        return Colors.orange;
      case ProjectHealth.critical:
        return Colors.red;
    }
  }
  
  String _getStatusDisplayName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return AppStrings.projectStatusPlanning.tr;
      case ProjectStatus.active:
        return AppStrings.projectStatusActive.tr;
      case ProjectStatus.onHold:
        return AppStrings.projectStatusOnHold.tr;
      case ProjectStatus.completed:
        return AppStrings.projectStatusCompleted.tr;
      case ProjectStatus.cancelled:
        return AppStrings.projectStatusCancelled.tr;
      case ProjectStatus.archived:
        return AppStrings.projectStatusArchived.tr;
    }
  }

  void _showProjectDetail(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (project.description != null && project.description!.isNotEmpty) ...[
                Text(
                  AppStrings.description.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(project.description!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Text(
                    '${AppStrings.projectStatus.tr}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(_getStatusDisplayName(project.status)),
                    backgroundColor: _getStatusColor(project.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.projectProgress.tr}: ${(project.progress * 100).toStringAsFixed(0)}%',
              ),
              if (project.endDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.projectEndDate.tr}: ${_formatDate(project.endDate!)}',
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${AppStrings.projectDaysRemaining.tr}: ${project.daysRemaining}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.close.tr),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

enum ProjectView {
  grid,
  list,
}