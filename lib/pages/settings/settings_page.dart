import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/theme_service.dart';
import 'package:praxis/common/style/design_tokens.dart';

/// 设置页面（按设计稿重构）
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _iCloudSyncEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeService = Get.find<ThemeService>();
    
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
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? DesignTokens.surfaceDarkSecondary
                          : DesignTokens.surfaceLightSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '设置',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeTitleLarge,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DesignTokens.spacing6),
              children: [
                // 账号卡片
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spacing4),
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
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark
                              ? DesignTokens.surfaceDarkSecondary
                              : DesignTokens.surfaceLightSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex Chen',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeTitleLarge,
                                fontWeight: DesignTokens.fontWeightBold,
                                color: isDark
                                    ? DesignTokens.onSurfaceDark
                                    : DesignTokens.onSurfaceLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'alex.chen@example.com',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeBodySmall,
                                color: isDark
                                    ? DesignTokens.textSecondaryDark
                                    : DesignTokens.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing4,
                          vertical: DesignTokens.spacing2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? DesignTokens.surfaceDarkSecondary
                              : DesignTokens.surfaceLightSecondary,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                          border: Border.all(
                            color: isDark
                                ? DesignTokens.borderDark
                                : DesignTokens.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '编辑',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeLabelSmall,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: isDark
                                ? DesignTokens.onSurfaceDark
                                : DesignTokens.onSurfaceLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing6),
                
                // 通用设置
                Text(
                  '通用',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing3),
                
                Container(
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
                    children: [
                      _buildSettingItem(
                        icon: Icons.dark_mode,
                        iconColor: DesignTokens.primaryColor,
                        title: '深色模式',
                        subtitle: '跟随系统',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              final mode = themeService.themeMode;
                              String modeText = '跟随系统';
                              if (mode == ThemeMode.light) {
                                modeText = '浅色';
                              } else if (mode == ThemeMode.dark) {
                                modeText = '深色';
                              }
                              return Text(
                                modeText,
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeLabelSmall,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: isDark
                                      ? DesignTokens.textSecondaryDark
                                      : DesignTokens.textSecondaryLight,
                                ),
                              );
                            }),
                            const SizedBox(width: DesignTokens.spacing2),
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: isDark
                                  ? DesignTokens.textTertiaryDark
                                  : DesignTokens.textTertiaryLight,
                            ),
                          ],
                        ),
                        onTap: () {
                          _showThemeSelector(themeService, isDark);
                        },
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight,
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications,
                        iconColor: DesignTokens.secondaryOrange,
                        title: '通知提醒',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeColor: DesignTokens.primaryColor,
                        ),
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight,
                      ),
                      _buildSettingItem(
                        icon: Icons.language,
                        iconColor: DesignTokens.primaryColor,
                        title: '语言',
                        subtitle: '简体中文',
                        trailing: Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: isDark
                              ? DesignTokens.textTertiaryDark
                              : DesignTokens.textTertiaryLight,
                        ),
                        onTap: () {
                          // 语言选择
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing6),
                
                // 数据与安全
                Text(
                  '数据与安全',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing3),
                
                Container(
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
                    children: [
                      _buildSettingItem(
                        icon: Icons.cloud,
                        iconColor: DesignTokens.secondaryEmerald,
                        title: 'iCloud 同步',
                        trailing: Switch(
                          value: _iCloudSyncEnabled,
                          onChanged: (value) {
                            setState(() {
                              _iCloudSyncEnabled = value;
                            });
                          },
                          activeColor: DesignTokens.primaryColor,
                        ),
                        isDark: isDark,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? DesignTokens.borderDark
                            : DesignTokens.borderLight,
                      ),
                      _buildSettingItem(
                        icon: Icons.shield,
                        iconColor: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                        title: '隐私政策',
                        trailing: Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: isDark
                              ? DesignTokens.textTertiaryDark
                              : DesignTokens.textTertiaryLight,
                        ),
                        onTap: () {
                          // 打开隐私政策
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: DesignTokens.spacing8),
                
                // 退出登录按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 退出登录
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.spacing4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                        side: BorderSide(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '退出登录',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodySmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodySmall,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  if (subtitle != null) ...[
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
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(ThemeService themeService, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                    _buildThemeOption(
                      '浅色',
                      ThemeMode.light,
                      themeService,
                      isDark,
                    ),
                    _buildThemeOption(
                      '深色',
                      ThemeMode.dark,
                      themeService,
                      isDark,
                    ),
                    _buildThemeOption(
                      '跟随系统',
                      ThemeMode.system,
                      themeService,
                      isDark,
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

  Widget _buildThemeOption(
    String label,
    ThemeMode mode,
    ThemeService themeService,
    bool isDark,
  ) {
    return Obx(() {
      final isSelected = themeService.themeMode == mode;
      return GestureDetector(
        onTap: () {
          themeService.changeThemeMode(mode);
          Get.back();
        },
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spacing4),
          margin: const EdgeInsets.only(bottom: DesignTokens.spacing2),
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: DesignTokens.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      );
    });
  }
}
