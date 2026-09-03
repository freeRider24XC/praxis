import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:praxis/common/ai/services/ai_config_service.dart';
import 'ai_provider.dart';
import 'openai_provider.dart';

/// Dedicated Google Gemini AI provider.
class GeminiProvider implements AiProvider {
  GeminiProvider({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _maxAttempts = 3;

  Future<http.Response> _postWithRetry(
    Uri url, {
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final response = await _client
            .post(url, headers: headers, body: body)
            .timeout(timeout);
        final retryable = response.statusCode == 429 || response.statusCode >= 500;
        if (!retryable || attempt == _maxAttempts - 1) return response;
        await Future<void>.delayed(Duration(milliseconds: 200 * (1 << attempt)));
      } on TimeoutException {
        if (attempt == _maxAttempts - 1) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 200 * (1 << attempt)));
      }
    }
    throw StateError('Gemini request attempts exhausted');
  }

  @override
  Future<bool> isConfigured() async {
    final apiKey = await AiConfigService.getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  @override
  Future<String> chat(
    String message,
    List<ChatMessage> history, {
    String? systemPromptOverride,
  }) async {
    if (!await isConfigured()) {
      throw Exception('API密钥未配置，请在设置中配置API密钥');
    }

    final apiKey = await AiConfigService.getApiKey();
    if (apiKey == null) throw Exception('API密钥未配置');
    final baseUrl = AiConfigService.defaultBaseUrlForKind(AiProviderKind.gemini);
    final model = AiConfigService.defaultModelForKind(AiProviderKind.gemini);
    final url = Uri.parse('$baseUrl/models/$model:generateContent?key=$apiKey');

    final systemMsg = systemPromptOverride ??
        '你是一个友好的AI助手，帮助用户管理目标和任务。';

    final contents = <Map<String, dynamic>>[];

    contents.add({
      'role': 'user',
      'parts': [
        {'text': '[系统提示] $systemMsg\n\n用户: $message'}
      ],
    });

    for (final msg in history) {
      contents.add({
        'role': msg.role == 'assistant' ? 'model' : 'user',
        'parts': [{'text': msg.content}],
      });
    }

    final requestBody = {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2000,
      },
    };

    try {
      final response = await _postWithRetry(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
        timeout: const Duration(seconds: 30),
      );

      debugPrint('Gemini响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('AI返回了空响应');
        }
        final contentObj = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = contentObj?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception('AI返回了空响应');
        }
        return parts[0]['text'] as String? ?? '';
      } else if (response.statusCode == 401) {
        throw Exception('API密钥无效，请检查密钥是否正确');
      } else if (response.statusCode == 429) {
        throw Exception('API调用次数超限，请稍后再试');
      } else {
        throw Exception('API请求失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gemini异常: $e');
      rethrow;
    }
  }

  @override
  Future<String> structuredPlanningChat(
    String message, {
    List<ChatMessage> history = const [],
  }) {
    const planningPrompt =
        '你是Praxis AI规划助手。只返回JSON对象（无markdown）。';
    return chat(message, history, systemPromptOverride: planningPrompt);
  }

  @override
  Future<bool> testConnection() async {
    if (!await isConfigured()) return false;
    try {
      final apiKey = await AiConfigService.getApiKey();
      if (apiKey == null) return false;
      final baseUrl = AiConfigService.defaultBaseUrlForKind(AiProviderKind.gemini);
      final model = AiConfigService.defaultModelForKind(AiProviderKind.gemini);
      final url = Uri.parse('$baseUrl/models/$model:generateContent?key=$apiKey');

      final response = await _postWithRetry(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'role': 'user', 'parts': [{'text': 'Hi'}]}
          ],
          'generationConfig': {'maxOutputTokens': 5},
        }),
        timeout: const Duration(seconds: 10),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
