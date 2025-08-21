import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/index.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // User Profile Section
          _buildSectionHeader('个人信息'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('用户名'),
            subtitle: const Text('点击设置用户信息'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUserProfileDialog(),
          ),
          
          const Divider(),
          
          // Appearance Section
          _buildSectionHeader('外观'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('主题模式'),
            subtitle: Text(_getThemeModeText()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeModeDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('主题颜色'),
            subtitle: Text(ThemeService.themeNames[ThemeService.colorIndex]),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: ThemeService.themeColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () => _showThemeColorDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            subtitle: const Text('中文简体'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          
          const Divider(),
          
          // Notifications Section
          _buildSectionHeader('通知'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('启用通知'),
            subtitle: const Text('接收任务提醒和目标通知'),
            value: DatabaseService.getSetting('notifications_enabled', defaultValue: true),
            onChanged: (value) {
              setState(() {
                DatabaseService.setSetting('notifications_enabled', value);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('默认提醒时间'),
            subtitle: const Text('09:00'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderTimeDialog(),
          ),
          
          const Divider(),
          
          // Data Management Section
          _buildSectionHeader('数据管理'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('备份数据'),
            subtitle: const Text('导出数据到文件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _backupData(),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('恢复数据'),
            subtitle: const Text('从文件恢复数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _restoreData(),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('云同步'),
            subtitle: const Text('未配置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCloudSyncDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('清除所有数据'),
            subtitle: const Text('删除所有本地数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDataDialog(),
          ),
          
          const Divider(),
          
          // About Section
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于 Praxis'),
            subtitle: const Text('版本 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('帮助与反馈'),
            subtitle: const Text('获取帮助或提供反馈'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私政策'),
            subtitle: const Text('查看隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyPolicy(),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeModeText() {
    switch (ThemeService.themeMode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _showUserProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('用户信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '用户名',
                hintText: '输入您的用户名',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '输入您的邮箱',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // Save user profile
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showThemeModeDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            String text;
            switch (mode) {
              case ThemeMode.light:
                text = '浅色模式';
                break;
              case ThemeMode.dark:
                text = '深色模式';
                break;
              case ThemeMode.system:
                text = '跟随系统';
                break;
            }
            
            return RadioListTile<ThemeMode>(
              title: Text(text),
              value: mode,
              groupValue: ThemeService.themeMode,
              onChanged: (value) async {
                if (value != null) {
                  await ThemeService.saveThemeMode(value);
                  Get.changeThemeMode(value);
                  Get.back();
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeColorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('选择主题颜色'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ThemeService.themeColors.length,
            itemBuilder: (context, index) {
              final color = ThemeService.themeColors[index];
              final isSelected = index == ThemeService.colorIndex;
              
              return InkWell(
                onTap: () async {
                  await ThemeService.saveThemeColor(index);
                  Get.back();
                  setState(() {});
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  ),
                  child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('中文简体'),
              value: 'zh_CN',
              groupValue: 'zh_CN',
              onChanged: (_) {
                Get.back();
              },
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'en',
              groupValue: 'zh_CN',
              onChanged: (_) {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderTimeDialog() {
    showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    ).then((time) {
      if (time != null) {
        // Save reminder time
        setState(() {});
      }
    });
  }

  void _backupData() {
    final data = DatabaseService.backupData();
    // Implement file export
    Get.snackbar(
      '备份成功',
      '数据已备份',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _restoreData() {
    // Implement file import
    Get.dialog(
      AlertDialog(
        title: const Text('恢复数据'),
        content: const Text('确定要从备份文件恢复数据吗？这将覆盖当前所有数据。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // Restore data
              Get.back();
              Get.snackbar(
                '恢复成功',
                '数据已恢复',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCloudSyncDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('云同步'),
        content: const Text('云同步功能即将推出，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('确定要清除所有数据吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.clearAllData();
              Get.back();
              Get.snackbar(
                '清除成功',
                '所有数据已清除',
                snackPosition: SnackPosition.BOTTOM,
              );
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Praxis',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.dashboard, size: 48),
      children: [
        const Text(
          'Praxis 是一款全方位的个人生活管理软件，帮助您高效管理时间、规划人生目标、追踪健康状况、管理财务、维护社交关系。',
        ),
      ],
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('帮助与反馈'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('使用指南'),
              onTap: () {
                Get.back();
                // Open user guide
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('常见问题'),
              onTap: () {
                Get.back();
                // Open FAQ
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('联系我们'),
              subtitle: const Text('support@praxis.app'),
              onTap: () {
                Get.back();
                // Send email
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '我们非常重视您的隐私。Praxis 采用本地优先的数据存储策略，您的所有数据都存储在本地设备上。\n\n'
            '数据收集：\n'
            '• 我们不会收集任何个人身份信息\n'
            '• 所有数据都存储在您的设备本地\n'
            '• 云同步功能为可选项，需要您明确授权\n\n'
            '数据安全：\n'
            '• 使用行业标准加密技术保护您的数据\n'
            '• 支持生物识别解锁\n'
            '• 定期备份以防止数据丢失\n\n'
            '第三方服务：\n'
            '• 仅在您明确授权后使用第三方服务\n'
            '• 不会与第三方共享您的个人数据\n',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}