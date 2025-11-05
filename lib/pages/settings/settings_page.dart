import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/locale_service.dart';
import 'package:praxis/common/services/theme_service.dart';
import 'package:praxis/common/widgets/language_switcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 语言设置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const LanguageSelector(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 主题设置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'theme'.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: Text('lightTheme'.tr),
                    value: ThemeMode.light,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeService.changeThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('darkTheme'.tr),
                    value: ThemeMode.dark,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeService.changeThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('systemTheme'.tr),
                    value: ThemeMode.system,
                    groupValue: themeService.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        themeService.changeThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              )),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 应用信息
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'appInfo'.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text('appName'.tr),
                    subtitle: Text('version'.trParams({'version': '1.0.0'})),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: Text('description'.tr),
                    subtitle: Text('title'.tr),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}