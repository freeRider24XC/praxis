import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:praxis/common/ai/services/ai_config_service.dart';

Future<void> loadLocalApiConfig() async {
  try {
    final configFile = File('local_config/minimax_api_key.txt');
    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      final lines = content.split('\n');
      String? apiKey;

      for (final line in lines) {
        if (line.startsWith('API_KEY=')) {
          apiKey = line.split('=')[1].trim();
          break;
        }
      }

      if (apiKey != null && apiKey.isNotEmpty) {
        final currentKey = await AiConfigService.getApiKey();
        if (currentKey == null || currentKey.isEmpty) {
          await AiConfigService.setMiniMax(apiKey: apiKey);
          debugPrint('✅ 已从 local_config/minimax_api_key.txt 加载 MiniMax API 配置');
        }
      }
    }
  } catch (e) {
    debugPrint('⚠️ 加载本地API配置失败: $e');
  }
}
