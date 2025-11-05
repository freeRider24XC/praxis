import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/pages/todo/widgets/todo_list_item.dart';
import 'package:praxis/pages/todo/widgets/todo_filter_chip.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TodoFilter _currentFilter = TodoFilter.all;
  TodoPriority? _priorityFilter;
  String? _projectFilter;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('待办事项'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '今日'),
            Tab(text: '明日'),
            Tab(text: '本周'),
            Tab(text: '全部'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<TodoSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: _onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TodoSortOption.dueDate,
                child: Text('按截止日期'),
              ),
              const PopupMenuItem(
                value: TodoSortOption.priority,
                child: Text('按优先级'),
              ),
              const PopupMenuItem(
                value: TodoSortOption.createdDate,
                child: Text('按创建时间'),
              ),
              const PopupMenuItem(
                value: TodoSortOption.name,
                child: Text('按名称'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodoList(TodoTimeFilter.today),
                _buildTodoList(TodoTimeFilter.tomorrow),
                _buildTodoList(TodoTimeFilter.thisWeek),
                _buildTodoList(TodoTimeFilter.all),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          TodoFilterChip(
            label: '全部',
            selected: _currentFilter == TodoFilter.all,
            onSelected: (_) => setState(() {
              _currentFilter = TodoFilter.all;
            }),
          ),
          const SizedBox(width: 8),
          TodoFilterChip(
            label: '未完成',
            selected: _currentFilter == TodoFilter.pending,
            onSelected: (_) => setState(() {
              _currentFilter = TodoFilter.pending;
            }),
          ),
          const SizedBox(width: 8),
          TodoFilterChip(
            label: '已完成',
            selected: _currentFilter == TodoFilter.completed,
            onSelected: (_) => setState(() {
              _currentFilter = TodoFilter.completed;
            }),
          ),
          const SizedBox(width: 8),
          TodoFilterChip(
            label: '已逾期',
            selected: _currentFilter == TodoFilter.overdue,
            onSelected: (_) => setState(() {
              _currentFilter = TodoFilter.overdue;
            }),
          ),
          if (_priorityFilter != null) ...[
            const SizedBox(width: 8),
            TodoFilterChip(
              label: _priorityFilter!.displayName,
              selected: true,
              onDeleted: () => setState(() {
                _priorityFilter = null;
              }),
            ),
          ],
          if (_projectFilter != null) ...[
            const SizedBox(width: 8),
            TodoFilterChip(
              label: _projectFilter!,
              selected: true,
              onDeleted: () => setState(() {
                _projectFilter = null;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodoList(TodoTimeFilter timeFilter) {
    final todos = _filterTodos(DatabaseService.getAllTodos(), timeFilter);
    
    if (todos.isEmpty) {
      return _buildEmptyState(timeFilter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoListItem(
          todo: todo,
          onTap: () => _showTodoDetail(todo),
          onToggle: () => _toggleTodo(todo),
          onDelete: () => _deleteTodo(todo),
        );
      },
    );
  }

  Widget _buildEmptyState(TodoTimeFilter timeFilter) {
    String message;
    IconData icon;

    switch (timeFilter) {
      case TodoTimeFilter.today:
        message = '今天没有待办事项';
        icon = Icons.wb_sunny;
        break;
      case TodoTimeFilter.tomorrow:
        message = '明天没有待办事项';
        icon = Icons.calendar_today;
        break;
      case TodoTimeFilter.thisWeek:
        message = '本周没有待办事项';
        icon = Icons.date_range;
        break;
      case TodoTimeFilter.all:
        message = '暂无待办事项';
        icon = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
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
            onPressed: () => Get.toNamed('/todo/add'),
            icon: const Icon(Icons.add),
            label: const Text('添加待办事项'),
          ),
        ],
      ),
    );
  }

  List<Todo> _filterTodos(List<Todo> todos, TodoTimeFilter timeFilter) {
    // Apply time filter
    List<Todo> filtered = todos;
    
    switch (timeFilter) {
      case TodoTimeFilter.today:
        filtered = todos.where((todo) => todo.isDueToday).toList();
        break;
      case TodoTimeFilter.tomorrow:
        filtered = todos.where((todo) => todo.isDueTomorrow).toList();
        break;
      case TodoTimeFilter.thisWeek:
        filtered = todos.where((todo) => todo.isDueThisWeek).toList();
        break;
      case TodoTimeFilter.all:
        // No time filter
        break;
    }

    // Apply status filter
    switch (_currentFilter) {
      case TodoFilter.pending:
        filtered = filtered.where((todo) => !todo.isDone).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isDone).toList();
        break;
      case TodoFilter.overdue:
        filtered = filtered.where((todo) => todo.isOverdue).toList();
        break;
      case TodoFilter.all:
        // No status filter
        break;
    }

    // Apply priority filter
    if (_priorityFilter != null) {
      filtered = filtered.where((todo) => todo.priority == _priorityFilter).toList();
    }

    // Apply project filter
    if (_projectFilter != null) {
      filtered = filtered.where((todo) => todo.projectId == _projectFilter).toList();
    }

    return filtered;
  }

  void _showTodoDetail(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(todo.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (todo.description != null && todo.description!.isNotEmpty) ...[
                const Text(
                  '描述',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(todo.description!),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Text(
                    '优先级: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(todo.priority.displayName),
                    backgroundColor: _getPriorityColor(todo.priority),
                  ),
                ],
              ),
              if (todo.dueDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  '截止日期: ${_formatDate(todo.dueDate!)}',
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '状态: ${todo.isDone ? "已完成" : "未完成"}',
              ),
              if (todo.tags != null && todo.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  '标签: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 4,
                  children: todo.tags!.map((tag) => Chip(
                    label: Text(tag),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          if (!todo.isDone)
            ElevatedButton(
              onPressed: () {
                _toggleTodo(todo);
                Navigator.of(context).pop();
              },
              child: const Text('标记为完成'),
            ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
      case TodoPriority.urgent:
        return Colors.red.shade100;
      case TodoPriority.medium:
        return Colors.orange.shade100;
      case TodoPriority.low:
        return Colors.green.shade100;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _toggleTodo(Todo todo) {
    todo.toggleDone();
    setState(() {});
  }

  void _deleteTodo(Todo todo) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除待办事项'),
        content: Text('确定要删除"${todo.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.deleteTodo(todo);
      setState(() {});
    }
  }

  void _showSearchDialog() {
    // 暂时显示提示，搜索功能待实现
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索功能'),
        content: const Text('搜索功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _onSortChanged(TodoSortOption option) {
    // Implement sort logic
    setState(() {});
  }
}

enum TodoFilter {
  all,
  pending,
  completed,
  overdue,
}

enum TodoTimeFilter {
  today,
  tomorrow,
  thisWeek,
  all,
}

enum TodoSortOption {
  dueDate,
  priority,
  createdDate,
  name,
}