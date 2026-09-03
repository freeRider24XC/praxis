import 'package:shared_preferences/shared_preferences.dart';
import 'package:praxis/common/services/secure_storage_service.dart';

enum AiProviderKind {
  openai,
  deepseek,
  tongyi,
  gemini,
  minimax,
  custom,
}

class AiConfigService {
  static const String _keyApiKey = 'ai_api_key';
  static const String _keyApiBaseUrl = 'ai_api_base_url';
  static const String _keyModel = 'ai_model';

  static final _secure = SecureStorageService();

  /// Test override — set this in setUp to control what getApiKey returns.
  /// Accessible within the ai library for testing only.
  static SecureStorageService? testSecureOverride;

  // 默认值
  static const String defaultBaseUrl = 'https://api.openai.com/v1';
  static const String defaultDeepSeekUrl = 'https://api.deepseek.com/v1';
  static const String defaultTongyiUrl =
      'https://dashscope.aliyuncs.com/api/v1';
  static const String defaultGeminiUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String defaultMiniMaxUrl = 'https://api.minimax.chat/v1';
  static const String defaultModel = 'gpt-3.5-turbo';

  // 获取API密钥（兼容接口；区分未配置与存储失败请用 readKey）
  static Future<String?> getApiKey() async {
    final storage = testSecureOverride ?? _secure;
    final result = await storage.read(_keyApiKey);
    if (result is SecureReadOk<String?>) return result.value;
    return null; // storage error or unconfigured
  }

  // 设置API密钥（安全存储）
  static Future<SecureStorageResult<void>> setApiKeySecure(String apiKey) async {
    return _secure.write(_keyApiKey, apiKey);
  }

  // 兼容旧接口：迁移期同时写两份
  static Future<bool> setApiKey(String apiKey) async {
    final result = await setApiKeySecure(apiKey);
    if (result is! SecureWriteOk) return false;
    // 同时写 SharedPreferences 保持向后兼容
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyApiKey, apiKey);
    } catch (_) { /* 忽略 SharedPreferences 写入失败 */ }
    return true;
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

  static AiProviderKind detectProviderKind(String baseUrl) {
    if (baseUrl.contains('api.openai.com')) {
      return AiProviderKind.openai;
    }
    if (baseUrl.contains('api.deepseek.com')) {
      return AiProviderKind.deepseek;
    }
    if (baseUrl.contains('dashscope.aliyuncs.com')) {
      return AiProviderKind.tongyi;
    }
    if (baseUrl.contains('generativelanguage.googleapis.com')) {
      return AiProviderKind.gemini;
    }
    if (baseUrl.contains('api.minimax.chat')) {
      return AiProviderKind.minimax;
    }
    return AiProviderKind.custom;
  }

  static String providerLabelForKind(AiProviderKind kind) {
    switch (kind) {
      case AiProviderKind.openai:
        return 'OpenAI';
      case AiProviderKind.deepseek:
        return 'DeepSeek';
      case AiProviderKind.tongyi:
        return '通义千问';
      case AiProviderKind.gemini:
        return 'Gemini';
      case AiProviderKind.minimax:
        return 'MiniMax';
      case AiProviderKind.custom:
        return '自定义';
    }
  }

  static Future<AiProviderKind> getProviderKind() async {
    final baseUrl = await getApiBaseUrl();
    return detectProviderKind(baseUrl);
  }

  static Future<String> getProviderLabel() async {
    return providerLabelForKind(await getProviderKind());
  }

  static Future<String?> getMaskedApiKey() async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;
    if (apiKey.length <= 8) return '*' * apiKey.length;
    return '${apiKey.substring(0, 4)}****${apiKey.substring(apiKey.length - 4)}';
  }

  static String defaultBaseUrlForKind(AiProviderKind kind) {
    switch (kind) {
      case AiProviderKind.openai:
        return defaultBaseUrl;
      case AiProviderKind.deepseek:
        return defaultDeepSeekUrl;
      case AiProviderKind.tongyi:
        return defaultTongyiUrl;
      case AiProviderKind.gemini:
        return defaultGeminiUrl;
      case AiProviderKind.minimax:
        return defaultMiniMaxUrl;
      case AiProviderKind.custom:
        return defaultBaseUrl;
    }
  }

  static String defaultModelForKind(AiProviderKind kind) {
    switch (kind) {
      case AiProviderKind.openai:
        return 'gpt-4o-mini';
      case AiProviderKind.deepseek:
        return 'deepseek-chat';
      case AiProviderKind.tongyi:
        return 'qwen-turbo';
      case AiProviderKind.gemini:
        return 'gemini-1.5-flash';
      case AiProviderKind.minimax:
        return 'abab6.5s-chat';
      case AiProviderKind.custom:
        return defaultModel;
    }
  }

  // 清除配置
  static Future<bool> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyApiKey);
      await _secure.delete(_keyApiKey);
      await prefs.remove(_keyApiBaseUrl);
      await prefs.remove(_keyModel);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 设置使用OpenAI
  static Future<void> setOpenAI(
      {required String apiKey, String model = 'gpt-3.5-turbo'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultBaseUrl);
    await setModel(model);
  }

  // 设置使用DeepSeek
  static Future<void> setDeepSeek(
      {required String apiKey, String model = 'deepseek-chat'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultDeepSeekUrl);
    await setModel(model);
  }

  // 设置使用通义千问（Tongyi Qianwen）- 免费额度
  static Future<void> setTongyi(
      {required String apiKey, String model = 'qwen-turbo'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultTongyiUrl);
    await setModel(model);
  }

  // 设置使用Gemini（Google）
  static Future<void> setGemini(
      {required String apiKey, String model = 'gemini-pro'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultGeminiUrl);
    await setModel(model);
  }

  // 设置使用MiniMax
  static Future<void> setMiniMax(
      {required String apiKey, String model = 'abab6.5s-chat'}) async {
    await setApiKey(apiKey);
    await setApiBaseUrl(defaultMiniMaxUrl);
    await setModel(model);
  }
}
