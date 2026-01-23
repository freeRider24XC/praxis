/// MiniMax API 配置脚本
/// 使用方法: dart scripts/setup_minimax.dart <api_key>
///
/// 注意: 此脚本用于本地开发环境配置，API密钥不会提交到版本控制系统

import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('错误: 请提供 MiniMax API 密钥');
    print('使用方法: dart scripts/setup_minimax.dart <api_key>');
    print('');
    print('示例:');
    print('  dart scripts/setup_minimax.dart sk-cp-xxxxx');
    return;
  }

  final apiKey = arguments[0];

  if (apiKey.isEmpty) {
    print('错误: API 密钥不能为空');
    return;
  }

  print('正在配置 MiniMax API...');

  try {
    final prefs = await SharedPreferences.getInstance();

    // 设置 API 密钥
    await prefs.setString('ai_api_key', apiKey);

    // 设置 MiniMax API 地址
    await prefs.setString('ai_api_base_url', 'https://api.minimax.chat/v1');

    // 设置模型
    await prefs.setString('ai_model', 'abab6.5s-chat');

    print('✓ MiniMax API 配置成功!');
    print('');
    print('配置信息:');
    print('  API 地址: https://api.minimax.chat/v1');
    print('  模型: abab6.5s-chat');
    print('');
    print('提示: API 密钥已保存在本地存储中');
  } catch (e) {
    print('配置失败: $e');
  }
}
