import 'package:zx/common/ai/providers/openai_provider.dart';

// 导出ChatMessage以便外部使用
export 'package:zx/common/ai/providers/openai_provider.dart' show ChatMessage;

class AiService {
  final OpenAIProvider _provider = OpenAIProvider();
  
  // 对话历史
  final List<ChatMessage> _history = [];

  // 获取对话历史
  List<ChatMessage> get history => List.unmodifiable(_history);

  // 检查是否已配置
  Future<bool> isConfigured() async {
    return await _provider.isConfigured();
  }

  // 发送消息
  Future<String> sendMessage(String message) async {
    if (!await isConfigured()) {
      throw Exception('API密钥未配置，请在设置中配置API密钥');
    }

    // 添加用户消息到历史
    _history.add(ChatMessage(role: 'user', content: message));

    try {
      // 调用AI
      final response = await _provider.chat(message, _history);
      
      // 添加AI回复到历史
      _history.add(ChatMessage(role: 'assistant', content: response));
      
      return response;
    } catch (e) {
      // 如果失败，移除用户消息
      _history.removeLast();
      rethrow;
    }
  }

  // 清除对话历史
  void clearHistory() {
    _history.clear();
  }

  // 获取最后一条消息
  ChatMessage? getLastMessage() {
    return _history.isEmpty ? null : _history.last;
  }

  // 测试连接
  Future<bool> testConnection() async {
    return await _provider.testConnection();
  }
}

