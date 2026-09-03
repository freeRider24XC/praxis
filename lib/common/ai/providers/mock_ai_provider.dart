import 'ai_provider.dart';
import 'openai_provider.dart';

/// Mock AI provider for offline development and testing.
/// Returns canned, deterministic responses without network access.
class MockAiProvider implements AiProvider {
  MockAiProvider({this.shouldFail = false});

  /// When true, all methods throw instead of returning canned responses.
  final bool shouldFail;

  @override
  Future<bool> isConfigured() async => !shouldFail;

  @override
  Future<String> chat(
    String message,
    List<ChatMessage> history, {
    String? systemPromptOverride,
  }) async {
    if (shouldFail) {
      throw Exception('Mock AI: 模拟连接失败');
    }

    final lower = message.toLowerCase();
    if (lower.contains('目标') || lower.contains('goal')) {
      return '{"goal":{"title":"学习Flutter","description":"掌握Flutter开发"},"projects":[{"title":"环境搭建","description":"安装SDK","todoIds":[]}]}';
    }
    if (lower.contains('测试') || lower.contains('test')) {
      return '这是来自 Mock AI 的测试响应。功能正常运行中。';
    }
    return 'Mock AI 响应: "$message"。历史消息: ${history.length} 条。';
  }

  @override
  Future<String> structuredPlanningChat(
    String message, {
    List<ChatMessage> history = const [],
  }) async {
    if (shouldFail) throw Exception('Mock AI: 模拟连接失败');
    return '{"goal":{"title":"Mock Goal","description":"来自MockProvider"},"projects":[]}';
  }

  @override
  Future<bool> testConnection() async => !shouldFail;
}
