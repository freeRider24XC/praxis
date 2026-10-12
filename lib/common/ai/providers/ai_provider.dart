import 'openai_provider.dart' show ChatMessage;

/// Provider contract shared by remote and local AI implementations.
abstract interface class AiProvider {
  Future<bool> isConfigured();
  Future<String> chat(
    String message,
    List<ChatMessage> history, {
    String? systemPromptOverride,
  });
  Future<String> structuredPlanningChat(
    String message, {
    List<ChatMessage> history,
  });
  Future<bool> testConnection();
}
