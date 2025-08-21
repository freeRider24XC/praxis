import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/pages/todo/todo_page.dart';
import 'package:praxis/pages/goal/goal_page.dart';
import 'package:praxis/pages/project/project_page.dart';
import 'package:praxis/pages/stats/stats_page.dart';
import 'package:praxis/pages/settings/settings_page.dart';

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
    const ProjectPage(),
    const StatsPage(),
    const SettingsPage(),
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
      icon: Icon(Icons.folder_outlined),
      selectedIcon: Icon(Icons.folder),
      label: '项目',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: '统计',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: '设置',
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
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex >= 3) return null; // No FAB for stats and settings

    IconData icon;
    String tooltip;
    VoidCallback onPressed;

    switch (_currentIndex) {
      case 0: // Todo
        icon = Icons.add;
        tooltip = '添加待办';
        onPressed = () => _showAddTodoDialog();
        break;
      case 1: // Goal
        icon = Icons.flag;
        tooltip = '创建目标';
        onPressed = () => _showAddGoalDialog();
        break;
      case 2: // Project
        icon = Icons.create_new_folder;
        tooltip = '新建项目';
        onPressed = () => _showAddProjectDialog();
        break;
      default:
        return null;
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
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