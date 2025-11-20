import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/widgets/glass_nav_bar.dart';
import 'package:praxis/common/widgets/fab_button.dart';
import 'package:praxis/pages/home/home_page.dart';
import 'package:praxis/pages/explore/explore_page.dart';
import 'package:praxis/pages/ai_chat/ai_interaction_page.dart';
import 'package:praxis/pages/schedule/schedule_page.dart';
import 'package:praxis/pages/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const AiInteractionPage(),
    const SchedulePage(),
    const ProfilePage(),
  ];

  final List<NavBarItem> _navItems = const [
    NavBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: '首页',
    ),
    NavBarItem(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      label: '发现',
    ),
    NavBarItem(
      icon: Icons.smart_toy_outlined,
      selectedIcon: Icons.smart_toy,
      label: 'AI',
    ),
    NavBarItem(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: '日程',
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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          
          // 居中悬浮FAB（仅在首页显示）
          if (_currentIndex == 0)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: FabButton(
                  icon: Icons.add,
                  onPressed: () {
                    Get.to(() => const AiInteractionPage());
                  },
                ),
              ),
            ),
        ],
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