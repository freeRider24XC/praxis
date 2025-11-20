import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/goal.dart';
import 'package:praxis/common/models/project.dart';
import 'package:praxis/pages/settings/settings_page.dart';
import 'package:get/get.dart';

/// 个人中心页（按设计稿重构）
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todos = DatabaseService.getAllTodos();
    final completedTodos = todos.where((t) => t.isDone).length;
    final focusHours = 42; // 可以从统计数据中获取
    
    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: Column(
        children: [
          // 顶部栏
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing6,
              vertical: DesignTokens.spacing4,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? DesignTokens.backgroundDark
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '个人中心',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeHeadlineSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                  onPressed: () {
                    Get.to(() => const SettingsPage());
                  },
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              children: [
                // 用户信息卡片
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacing8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? DesignTokens.surfaceDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge + 8),
                    boxShadow: DesignTokens.shadowIOS,
                  ),
                  child: Row(
                    children: [
                      // 头像
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DesignTokens.primaryColor,
                              DesignTokens.secondaryPurple,
                              DesignTokens.secondaryOrange,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: DesignTokens.shadowFloat,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? DesignTokens.surfaceDark
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: DesignTokens.primaryColor,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: DesignTokens.spacing5),
                      
                      // 用户信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex Chen',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeHeadlineSmall,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: isDark
                                    ? DesignTokens.onSurfaceDark
                                    : DesignTokens.onSurfaceLight,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spacing1),
                            Text(
                              'Lv.5 规划大师',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeBodySmall,
                                fontWeight: DesignTokens.fontWeightMedium,
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spacing3),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? DesignTokens.surfaceDarkSecondary
                                          : DesignTokens.surfaceLightSecondary,
                                      borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: 0.7,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: DesignTokens.primaryColor,
                                          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.spacing2),
                                Text(
                                  '1200 XP',
                                  style: DesignTokens.textStyle(
                                    fontSize: 10,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: DesignTokens.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing8),
                
                // 数据概览
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: DesignTokens.spacing4,
                  mainAxisSpacing: DesignTokens.spacing4,
                  children: [
                    _buildStatCard(
                      icon: Icons.check_circle,
                      value: completedTodos.toString(),
                      label: '完成任务',
                      color: DesignTokens.secondaryEmerald,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      icon: Icons.hourglass_empty,
                      value: '$focusHours',
                      unit: 'h',
                      label: '专注时长',
                      color: DesignTokens.primaryColor,
                      isDark: isDark,
                    ),
                  ],
                ),
                
                const SizedBox(height: DesignTokens.spacing8),
                
                // 勋章墙
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '勋章收藏',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeTitleLarge,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: isDark
                                ? DesignTokens.onSurfaceDark
                                : DesignTokens.onSurfaceLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // 查看全部勋章
                          },
                          child: Row(
                            children: [
                              Text(
                                '查看全部',
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeLabelSmall,
                                  color: isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(width: DesignTokens.spacing1),
                              Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: DesignTokens.spacing4),
                    
                    Container(
                      padding: const EdgeInsets.all(DesignTokens.spacing6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignTokens.surfaceDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                        border: Border.all(
                          color: isDark
                              ? DesignTokens.borderDark
                              : DesignTokens.borderLight,
                          width: 0.5,
                        ),
                        boxShadow: DesignTokens.shadowIOS,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBadge('🏆', '7日连胜', true, isDark),
                          _buildBadge('⚡️', '效率之星', true, isDark),
                          _buildBadge('🧘', '冥想大师', false, isDark),
                          _buildBadge('📅', '全勤月', false, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: DesignTokens.spacing16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
    String? unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark
              ? DesignTokens.borderDark
              : DesignTokens.borderLight,
          width: 0.5,
        ),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: DesignTokens.textStyle(
                  fontSize: 32,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
              if (unit != null) ...[
                Text(
                  unit,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyMedium,
                    fontWeight: DesignTokens.fontWeightMedium,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DesignTokens.spacing1),
          Text(
            label,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeLabelSmall,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, String label, bool isUnlocked, bool isDark) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      DesignTokens.secondaryOrange.withOpacity(0.1),
                      DesignTokens.secondaryOrange.withOpacity(0.2),
                    ],
                  )
                : null,
            color: isUnlocked
                ? null
                : (isDark
                    ? DesignTokens.surfaceDarkSecondary
                    : DesignTokens.surfaceLightSecondary),
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            border: Border.all(
              color: isUnlocked
                  ? DesignTokens.secondaryOrange.withOpacity(0.3)
                  : (isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight),
              width: 1,
            ),
            boxShadow: isUnlocked ? DesignTokens.shadowIOS : null,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 28,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacing2),
        Text(
          label,
          style: DesignTokens.textStyle(
            fontSize: 10,
            fontWeight: DesignTokens.fontWeightBold,
            color: isUnlocked
                ? (isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight)
                : (isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight),
          ),
        ),
      ],
    );
  }
}
