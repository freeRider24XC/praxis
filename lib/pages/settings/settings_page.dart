import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/locale_service.dart';
import 'package:praxis/common/services/theme_service.dart';
import 'package:praxis/common/ai/services/ai_config_service.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/widgets/language_switcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  String? _selectedProvider = 'openai';
  bool _isLoading = false;
  bool _isConfigured = false;
  
  // 默认API密钥（仅在开发环境使用）
  static const String _defaultApiKey = 'sk-6aed399eac434b389bd831bff6f456d1';

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    final configured = await AiConfigService.isConfigured();
    final apiKey = await AiConfigService.getApiKey();
    final baseUrl = await AiConfigService.getApiBaseUrl();
    
    setState(() {
      _isConfigured = configured;
      if (apiKey != null) {
        _apiKeyController.text = apiKey;
      }
      if (baseUrl.contains('deepseek')) {
        _selectedProvider = 'deepseek';
      } else if (baseUrl.contains('dashscope')) {
        _selectedProvider = 'tongyi';
      } else {
        _selectedProvider = 'openai';
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    if (_apiKeyController.text.trim().isEmpty) {
      if (mounted) {
        Get.snackbar('错误', '请输入API密钥', snackPosition: SnackPosition.BOTTOM);
      }
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedProvider == 'openai') {
        await AiConfigService.setOpenAI(apiKey: _apiKeyController.text.trim());
      } else if (_selectedProvider == 'deepseek') {
        await AiConfigService.setDeepSeek(apiKey: _apiKeyController.text.trim());
      } else if (_selectedProvider == 'tongyi') {
        await AiConfigService.setTongyi(apiKey: _apiKeyController.text.trim());
      }

      // 测试连接
      bool testResult = false;
      String? testErrorMsg;
      try {
        final provider = OpenAIProvider();
        testResult = await provider.testConnection();
      } catch (e) {
        // 测试连接失败，但配置已保存
        testResult = false;
        testErrorMsg = e.toString().replaceAll('Exception: ', '');
        debugPrint('测试连接失败: $testErrorMsg');
      }

      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _isConfigured = testResult;
      });

      if (testResult) {
        Get.snackbar(
          '成功',
          'API密钥配置成功',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      } else {
        Get.snackbar(
          '警告',
          '配置已保存，但测试连接失败${testErrorMsg != null ? ': $testErrorMsg' : ''}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      Get.snackbar(
        '错误',
        '配置失败: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _clearConfiguration() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除API密钥配置吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AiConfigService.clearConfig();
      setState(() {
        _isConfigured = false;
        _apiKeyController.clear();
      });
      Get.snackbar('成功', '配置已清除', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // AI配置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy),
                      const SizedBox(width: 8),
                      Text(
                        'AI配置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (_isConfigured)
                        Chip(
                          label: const Text('已配置'),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: TextStyle(color: Colors.green.shade800),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    decoration: const InputDecoration(
                      labelText: 'AI服务提供商',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'openai',
                        child: Text('OpenAI (GPT)'),
                      ),
                      DropdownMenuItem(
                        value: 'deepseek',
                        child: Text('DeepSeek'),
                      ),
                      DropdownMenuItem(
                        value: 'tongyi',
                        child: Text('通义千问 (免费额度)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProvider = value ?? 'openai';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apiKeyController,
                          decoration: InputDecoration(
                            labelText: 'API密钥',
                            hintText: 'sk-...',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.visibility_off),
                              onPressed: () {
                                // TODO: 实现显示/隐藏密码
                              },
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _apiKeyController.text = _defaultApiKey;
                          });
                        },
                        icon: const Icon(Icons.auto_fix_high, size: 16),
                        label: const Text('使用默认'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'API密钥仅存储在本地，不会上传到服务器',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveConfiguration,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('保存配置'),
                        ),
                      ),
                      if (_isConfigured) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _clearConfiguration,
                          child: const Text('清除'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
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
                    '主题',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<ThemeMode>(
                    title: const Text('浅色'),
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
                    title: const Text('深色'),
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
                    title: const Text('跟随系统'),
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
                    '应用信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Praxis'),
                    subtitle: Text('版本 1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const ListTile(
                    leading: Icon(Icons.description),
                    title: Text('个人时间管理与规划软件'),
                    subtitle: Text('知行合一'),
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