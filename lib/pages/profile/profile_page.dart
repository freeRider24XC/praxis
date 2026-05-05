import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ProfileService.getProfile();
    final focusedDomain = DomainService.getFocusedDomain();
    final completedTodos =
        DatabaseService.getAllTodos().where((todo) => todo.isDone).length;
    final focusHours = DatabaseService.getTotalFocusDuration();
    final levelXp = XpService.xpIntoCurrentLevel(profile.totalXp);
    final levelMax = XpService.xpNeededWithinCurrentLevel(profile.totalXp);
    final progress = levelMax == 0 ? 0.0 : (levelXp / levelMax).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '个人',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeHeadlineSmall,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Get.to(() => const SettingsPage()),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing6),
            decoration: BoxDecoration(
              color: isDark ? DesignTokens.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
              boxShadow: DesignTokens.shadowIOS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: DesignTokens.primaryColor,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacing4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Praxis 用户',
                            style: DesignTokens.textStyle(
                              fontSize: DesignTokens.fontSizeTitleLarge,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: isDark
                                  ? DesignTokens.onSurfaceDark
                                  : DesignTokens.onSurfaceLight,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing1),
                          Text(
                            'Lv.${profile.level} · 连续 ${profile.streakDays} 天',
                            style: DesignTokens.textStyle(
                              color: isDark
                                  ? DesignTokens.textSecondaryDark
                                  : DesignTokens.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spacing2),
                          Text(
                            '当前重点：${focusedDomain?.icon ?? '🎯'} ${focusedDomain?.name ?? '未设置'}',
                            style: DesignTokens.textStyle(
                              fontWeight: DesignTokens.fontWeightMedium,
                              color: DesignTokens.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing4),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: isDark
                      ? DesignTokens.surfaceDarkSecondary
                      : DesignTokens.surfaceLightSecondary,
                ),
                const SizedBox(height: DesignTokens.spacing2),
                Text(
                  '${profile.totalXp} XP',
                  style: DesignTokens.textStyle(
                    fontWeight: DesignTokens.fontWeightBold,
                    color: DesignTokens.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing6),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: DesignTokens.spacing4,
            mainAxisSpacing: DesignTokens.spacing4,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                isDark: isDark,
                icon: Icons.check_circle_outline,
                label: '完成任务',
                value: completedTodos.toString(),
              ),
              _buildStatCard(
                isDark: isDark,
                icon: Icons.hourglass_bottom,
                label: '专注时长',
                value: '$focusHours h',
              ),
              _buildStatCard(
                isDark: isDark,
                icon: Icons.bolt_outlined,
                label: '总经验',
                value: profile.totalXp.toString(),
              ),
              _buildStatCard(
                isDark: isDark,
                icon: Icons.schedule,
                label: '每周可投入',
                value: '${profile.weeklyCapacityHours} h',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: DesignTokens.primaryColor),
          Text(
            value,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeHeadlineSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          Text(
            label,
            style: DesignTokens.textStyle(
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
