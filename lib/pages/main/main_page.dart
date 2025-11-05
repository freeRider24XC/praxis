import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/pages/todo/todo_page.dart';
import 'package:praxis/pages/goal/goal_page.dart';
import 'package:praxis/pages/project/project_page.dart';
import 'package:praxis/pages/stats/stats_page.dart';
import 'package:praxis/pages/ai_chat/ai_chat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const TodoPage(),
    const GoalPage(),
    const AiChatPage(),
    const ProjectPage(),
    const StatsPage(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.check_circle_outline),
      selectedIcon: Icon(Icons.check_circle),
      label: '待办',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: '目标',
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'AI助手',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: '项目',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: '统计',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget? _buildFloatingActionButton() {
    // AI助手页面不需要FAB
    if (_currentIndex == 2) {
      return null;
    }
    
    // 统计页面不需要FAB
    if (_currentIndex == 4) {
        return null;
    }

    // 其他页面显示原有功能按钮
    return FloatingActionButton(
      heroTag: 'fab_button',
      onPressed: _getFabAction(),
      tooltip: _getFabTooltip(),
      child: Icon(_getFabIcon()),
    );
  }

  IconData _getFabIcon() {
    switch (_currentIndex) {
      case 0:
        return Icons.add;
      case 1:
        return Icons.flag;
      case 3:
        return Icons.create_new_folder;
      default:
        return Icons.add;
    }
  }

  String _getFabTooltip() {
    switch (_currentIndex) {
      case 0:
        return '添加待办';
      case 1:
        return '创建目标';
      case 3:
        return '新建项目';
      default:
        return '添加';
    }
  }

  VoidCallback _getFabAction() {
    switch (_currentIndex) {
      case 0:
        return _showAddTodoDialog;
      case 1:
        return _showAddGoalDialog;
      case 3:
        return _showAddProjectDialog;
      default:
        return () {};
    }
  }

  void _showAddTodoDialog() {
    Get.toNamed('/todo/add');
  }

  void _showAddGoalDialog() {
    Get.toNamed('/goal/add');
  }

  void _showAddProjectDialog() {
    Get.toNamed('/project/add');
  }
}