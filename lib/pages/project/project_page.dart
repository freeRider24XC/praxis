import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/common/services/database_service.dart';

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
        title: Text('projectManagement'.tr),
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
                child: Text('allProjects'.tr),
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
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectGridCard(project);
      },
    );
  }

  Widget _buildListView(List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectListCard(project);
      },
    );
  }

  Widget _buildProjectGridCard(Project project) {
    final theme = Theme.of(context);
    final color = _parseColor(project.color);

    return Card(
      child: InkWell(
        onTap: () => _showProjectDetail(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        'progressPercentage'.trParams({
                          'percentage': (project.progress * 100).toInt().toString()
                        }),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (project.daysRemaining > 0)
                        Text(
                          'daysRemaining'.trParams({
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
      ),
    );
  }

  Widget _buildProjectListCard(Project project) {
    final theme = Theme.of(context);
    final color = _parseColor(project.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProjectDetail(project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          'progressPercentage'.trParams({
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
                            'taskCount'.trParams({
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
                            'daysRemaining'.trParams({
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _statusFilter != null 
              ? 'noProjectsWithStatus'.trParams({
                  'status': _getStatusDisplayName(_statusFilter!)
                })
              : 'notCreatedAnyProjects'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/project/add'),
            icon: const Icon(Icons.add),
            label: Text('createProject'.tr),
          ),
        ],
      ),
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
        return 'projectStatusPlanning'.tr;
      case ProjectStatus.active:
        return 'projectStatusActive'.tr;
      case ProjectStatus.onHold:
        return 'projectStatusOnHold'.tr;
      case ProjectStatus.completed:
        return 'projectStatusCompleted'.tr;
      case ProjectStatus.cancelled:
        return 'projectStatusCancelled'.tr;
      case ProjectStatus.archived:
        return 'projectStatusArchived'.tr;
    }
  }

  void _showProjectDetail(Project project) {
    Get.toNamed('/project/detail', arguments: project);
  }
}

enum ProjectView {
  grid,
  list,
}