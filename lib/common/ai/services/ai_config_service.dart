import 'package:shared_preferences/shared_preferences.dart';

class AiConfigService {
  static const String _keyApiKey = 'ai_api_key';
  static const String _keyApiBaseUrl = 'ai_api_base_url';
  static const String _keyModel = 'ai_model';
  
  // 默认值
  static const String defaultBaseUrl = 'https://api.openai.com/v1';
  static const String defaultDeepSeekUrl = 'https://api.deepseek.com/v1';
  static const String defaultModel = 'gpt-3.5-turbo';

  // 获取API密钥
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyApiKey);
    } catch (e) {
      return null;
    }
  }

  // 设置API密钥
  static Future<bool> setApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyApiKey, apiKey);
    } catch (e) {
      return false;
    }
  }

  // 获取API基础URL
  static Future<String> getApiBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyApiBaseUrl) ?? defaultBaseUrl;
    } catch (e) {
      return defaultBaseUrl;
    }
  }

  // 设置API基础URL
  static Future<bool> setApiBaseUrl(String baseUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyApiBaseUrl, baseUrl);
    } catch (e) {
      return false;
    }
  }

  // 获取模型名称
  static Future<String> getModel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyModel) ?? defaultModel;
    } catch (e) {
      return defaultModel;
    }
  }

  // 设置模型名称
  static Future<bool> setModel(String model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_keyModel, model);
    } catch (e) {
      return false;
    }
  }

  // 检查是否已配置
  static Future<bool> isConfigured() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // 清除配置
  static Future<bool> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyApiKey);
      await prefs.remove(_keyApiBaseUrl);
      await prefs.remove(_keyModel);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 设置使用OpenAI
  static Future<void> setOpenAI({required String apiKey, String model = 'gpt-3.5-turbo'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultBaseUrl);
    await setModel(model);
  }

  // 设置使用DeepSeek
  static Future<void> setDeepSeek({required String apiKey, String model = 'deepseek-chat'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultDeepSeekUrl);
    await setModel(model);
  }
}

