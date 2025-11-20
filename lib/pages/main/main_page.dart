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

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? DesignTokens.surfaceDark
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(DesignTokens.radiusXLarge),
              topRight: Radius.circular(DesignTokens.radiusXLarge),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: DesignTokens.spacing3),
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.borderDark
                        : DesignTokens.borderLight,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacing6),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.check_circle_outline,
                        title: '创建待办事项',
                        subtitle: '添加新的任务',
                        onTap: () {
                          Get.back();
                          Get.toNamed('/todo/add');
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.folder_outlined,
                        title: '创建项目',
                        subtitle: '开始新的项目',
                        onTap: () {
                          Get.back();
                          Get.toNamed('/project/add');
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.flag_outlined,
                        title: '创建目标',
                        subtitle: '设定新的目标',
                        onTap: () {
                          Get.back();
                          Get.toNamed('/goal/add');
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.smart_toy_outlined,
                        title: 'AI智能规划',
                        subtitle: '让AI帮你拆解任务',
                        onTap: () {
                          Get.back();
                          Get.to(() => const AiInteractionPage());
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        decoration: BoxDecoration(
          color: isDark
              ? DesignTokens.surfaceDarkSecondary
              : DesignTokens.surfaceLightSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DesignTokens.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              child: Icon(
                icon,
                color: DesignTokens.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? DesignTokens.textTertiaryDark
                  : DesignTokens.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
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
                      _showCreateMenu(context);
                    },
                  ),
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