import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:praxis/common/ai/services/ai_config_service.dart';

class ChatMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'],
        content: json['content'],
      );
}

class OpenAIProvider {
  // 系统提示词
  static const String systemPrompt = '''你是Praxis AI助手，帮助用户拆解目标、制定任务、安排日程。

当用户想要创建待办事项时，请在回复的自然语言后面添加JSON格式：
{
  "action": "create_todo",
  "title": "任务标题",
  "description": "任务描述",
  "priority": "high|medium|low",
  "dueDate": "YYYY-MM-DD"
}

当用户想要创建目标时，请返回：
{
  "action": "create_goal",
  "title": "目标标题",
  "description": "目标描述",
  "type": "year|quarter|month|week",
  "targetDate": "YYYY-MM-DD"
}

当用户需要拆解目标时，请返回多个待办事项的JSON数组。

如果用户只是在聊天，不需要创建实体，则只返回自然语言回复，不要包含JSON。''';

  // 检查是否已配置
  Future<bool> isConfigured() async {
    return await AiConfigService.isConfigured();
  }

  // 发送聊天消息
  Future<String> chat(String message, List<ChatMessage> history) async {
    if (!await isConfigured()) {
      throw Exception('API密钥未配置，请在设置中配置API密钥');
    }

    final apiKey = await AiConfigService.getApiKey();
    final baseUrl = await AiConfigService.getApiBaseUrl();
    final model = await AiConfigService.getModel();
    
    // 判断是否为通义千问API
    final isTongyi = baseUrl.contains('dashscope');

    // 构建消息列表
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      ...history.map((msg) => msg.toJson()),
      {'role': 'user', 'content': message},
    ];

    // 通义千问使用不同的API端点
    final endpoint = isTongyi 
        ? 'services/aigc/text-generation/generation'
        : 'chat/completions';
    final url = Uri.parse('$baseUrl/$endpoint');
    
    // 构建请求体
    Map<String, dynamic> requestBody;
    if (isTongyi) {
      // 通义千问的API格式
      requestBody = {
        'model': model,
        'input': {
          'messages': messages,
        },
        'parameters': {
          'temperature': 0.7,
          'max_tokens': 2000,
        },
      };
    } else {
      // OpenAI格式
      requestBody = {
        'model': model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 2000,
      };
    }
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(requestBody),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw Exception('请求超时，请检查网络连接');
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      String content;
      if (isTongyi) {
        // 通义千问的响应格式
        final output = data['output'] as Map<String, dynamic>?;
        if (output != null) {
          content = output['text'] as String? ?? '';
        } else {
          throw Exception('AI返回了空响应');
        }
      } else {
        // OpenAI格式
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          content = choices[0]['message']['content'] as String;
        } else {
          throw Exception('AI返回了空响应');
        }
      }
      
      return content;
    } else if (response.statusCode == 401) {
      throw Exception('API密钥无效，请检查密钥是否正确');
    } else if (response.statusCode == 402) {
      final isTongyi = baseUrl.contains('dashscope');
      throw Exception(isTongyi 
        ? '账户余额不足，请前往阿里云DashScope平台充值' 
        : '账户余额不足，请前往DeepSeek平台充值');
    } else if (response.statusCode == 429) {
      throw Exception('API调用次数超限，请稍后再试');
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      final errorMessage = errorData['error']?['message'] ?? '请求失败';
      throw Exception('API请求失败: $errorMessage');
    }
  }

  // 测试连接
  Future<bool> testConnection() async {
    try {
      final apiKey = await AiConfigService.getApiKey();
      final baseUrl = await AiConfigService.getApiBaseUrl();
      final model = await AiConfigService.getModel();
      
      final isTongyi = baseUrl.contains('dashscope');

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API密钥未配置');
      }

      // 通义千问使用不同的API端点
      final endpoint = isTongyi 
          ? 'services/aigc/text-generation/generation'
          : 'chat/completions';
      final url = Uri.parse('$baseUrl/$endpoint');
      
      // 构建请求体
      Map<String, dynamic> requestBody;
      if (isTongyi) {
        requestBody = {
          'model': model,
          'input': {
            'messages': [
              {'role': 'user', 'content': 'Hello'}
            ],
          },
          'parameters': {
            'max_tokens': 5,
          },
        };
      } else {
        requestBody = {
          'model': model,
          'messages': [
            {'role': 'user', 'content': 'Hello'}
          ],
          'max_tokens': 5,
        };
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('请求超时，请检查网络连接');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (isTongyi) {
          final output = data['output'] as Map<String, dynamic>?;
          return output != null && output['text'] != null;
        } else {
          final choices = data['choices'] as List;
          return choices.isNotEmpty;
        }
      } else if (response.statusCode == 401) {
        throw Exception('API密钥无效，请检查密钥是否正确');
      } else if (response.statusCode == 402) {
        final isTongyiCheck = baseUrl.contains('dashscope');
        throw Exception(isTongyiCheck 
          ? '账户余额不足，请前往阿里云DashScope平台充值' 
          : '账户余额不足，请前往DeepSeek平台充值');
      } else if (response.statusCode == 429) {
        throw Exception('API调用次数超限，请稍后再试');
      } else {
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMessage = errorData['error']?['message'] ?? '请求失败';
          throw Exception('API请求失败: $errorMessage');
        } catch (_) {
          throw Exception('API请求失败: HTTP ${response.statusCode}');
        }
      }
    } catch (e) {
      // 重新抛出异常以便上层捕获
      throw e;
    }
  }
}

