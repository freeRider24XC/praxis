import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/glass_nav_bar.dart';
import 'package:praxis/pages/dashboard/dashboard_page.dart';
import 'package:praxis/pages/goal/goal_page.dart';
import 'package:praxis/pages/project/project_page.dart';
import 'package:praxis/pages/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    DashboardPage(),
    GoalPage(),
    ProjectPage(),
    ProfilePage(),
  ];

  final List<NavBarItem> _navItems = const [
    NavBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '首页',
    ),
    NavBarItem(
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
      label: '目标',
    ),
    NavBarItem(
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      label: '项目',
    ),
    NavBarItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: '个人',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: DesignTokens.durationNormal,
      curve: DesignTokens.curveDefault,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTap: _onDestinationSelected,
        items: _navItems,
        isDark: isDark,
      ),
    );
  }
}
