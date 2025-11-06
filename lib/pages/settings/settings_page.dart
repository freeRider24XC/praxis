import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/services/theme_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/ai/services/ai_config_service.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/widgets/language_switcher.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
import 'package:praxis/common/widgets/praxis_button.dart';
import 'package:praxis/common/widgets/praxis_text_field.dart';
import 'package:praxis/common/style/design_tokens.dart';

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
        ErrorService.showWarning('请输入API密钥');
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
        ErrorService.showSuccess('API密钥配置成功');
      } else {
        ErrorService.showWarning('配置已保存，但测试连接失败${testErrorMsg != null ? ': $testErrorMsg' : ''}');
      }
    } catch (e) {
      LoggerService.error('保存配置失败', 'SettingsPage', e);
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ErrorService.handleError(e, context: '保存配置');
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
      ErrorService.showSuccess('配置已清除');
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
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        children: [
          // AI配置
          PraxisCard(
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy),
                      const SizedBox(width: DesignTokens.spacing2),
                      Text(
                        'AI配置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (_isConfigured)
                        Chip(
                          label: const Text('已配置'),
                          backgroundColor: DesignTokens.successColor.withOpacity(0.2),
                          labelStyle: TextStyle(color: DesignTokens.successColor),
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    decoration: InputDecoration(
                      labelText: 'AI服务提供商',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing4,
                        vertical: DesignTokens.spacing4,
                      ),
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
                        child: Text('通义千问'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedProvider = value ?? 'openai';
                      });
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Row(
                    children: [
                      Expanded(
                        child: PraxisTextField(
                          controller: _apiKeyController,
                          label: 'API密钥',
                          hint: 'sk-...',
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing2),
                      PraxisButton(
                        text: '使用默认',
                        icon: Icons.auto_fix_high,
                        onPressed: () {
                          setState(() {
                            _apiKeyController.text = _defaultApiKey;
                          });
                        },
                        type: PraxisButtonType.outline,
                        size: PraxisButtonSize.medium,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacing2),
                  Text(
                    'API密钥仅存储在本地，不会上传到服务器',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Row(
                    children: [
                      Expanded(
                        child: PraxisButton(
                          text: '保存配置',
                          onPressed: _isLoading ? null : _saveConfiguration,
                          type: PraxisButtonType.primary,
                          size: PraxisButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isLoading,
                        ),
                      ),
                      if (_isConfigured) ...[
                        const SizedBox(width: DesignTokens.spacing2),
                        PraxisButton(
                          text: '清除',
                          onPressed: _clearConfiguration,
                          type: PraxisButtonType.outline,
                          size: PraxisButtonSize.large,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: DesignTokens.spacing4),
          
          // 语言设置
          PraxisCard(
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            child: const LanguageSelector(),
          ),
          
          const SizedBox(height: DesignTokens.spacing4),
          
          // 主题设置
          PraxisCard(
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主题',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
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
          
          const SizedBox(height: DesignTokens.spacing4),
          
          // 应用信息
          PraxisCard(
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '应用信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
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
        ],
      ),
    );
  }
}