import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/locale_service.dart';
import 'package:praxis/common/services/theme_service.dart';
import 'package:praxis/common/widgets/language_switcher.dart';
import 'package:praxis/generated/l10n.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final themeService = Get.find<ThemeService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
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
                    s.theme,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: Text(s.lightTheme),
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
                    title: Text(s.darkTheme),
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
                    title: Text(s.systemTheme),
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
                    'App Info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(s.appName),
                    subtitle: const Text('Version 1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Description'),
                    subtitle: Text(s.title),
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