import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/fab_button.dart';
import 'package:praxis/common/widgets/glass_nav_bar.dart';
import 'package:praxis/pages/ai_chat/ai_plan_page.dart';
import 'package:praxis/pages/dashboard/dashboard_page.dart';
import 'package:praxis/pages/life_domains/domains_page.dart';
import 'package:praxis/pages/goal/goal_page.dart';
import 'package:praxis/pages/profile/profile_page.dart';
import 'package:praxis/pages/review/daily_review_page.dart';

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
    DomainsPage(),
    GoalPage(),
    ProfilePage(),
  ];

  final List<NavBarItem> _navItems = const [
    NavBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '首页',
    ),
    NavBarItem(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      label: '领域',
    ),
    NavBarItem(
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag,
      label: '目标',
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

  Future<void> _openAiPlanning() async {
    await Get.to(() => const AiPlanPage(initialGoalText: ''));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
            if (_currentIndex == 0)
              Positioned(
                top: DesignTokens.spacing6,
                left: DesignTokens.spacing6,
                child: FabButton(
                  icon: Icons.nights_stay_outlined,
                  onPressed: () async {
                    await Get.to(() => const DailyReviewPage());
                    setState(() {});
                  },
                ),
              ),
            if (_currentIndex == 0)
              Positioned(
                top: DesignTokens.spacing6,
                right: DesignTokens.spacing6,
                child: FabButton(
                  icon: Icons.auto_awesome,
                  onPressed: _openAiPlanning,
                ),
              ),
          ],
        ),
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
