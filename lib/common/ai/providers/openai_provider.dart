import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zx/common/ai/services/ai_config_service.dart';

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
  static const String systemPrompt = '''你是ZhiXing AI助手，帮助用户拆解目标、制定任务、安排日程。

**重要：当用户要求创建任务或拆解目标时，请直接返回格式化的待办事项列表！**

**待办事项格式（每行一个任务）：**
```
1. 任务标题（截止日期：YYYY-MM-DD）[优先级：高/中/低]
2. 任务标题（截止日期：YYYY-MM-DD）[优先级：高/中/低]
3. 任务标题（截止日期：YYYY-MM-DD）[优先级：高/中/低]
```

**规则：**
1. 如果用户要求创建任务、拆解目标或制定计划，请直接返回格式化的待办事项列表
2. 每行格式：序号. 任务标题（截止日期：YYYY-MM-DD）[优先级：高/中/低]
3. 优先级可以是：高、中、低（如果没有指定，默认为中）
4. 截止日期可选，如果用户没有指定具体日期，可以省略或使用相对日期（如：明天、下周等）
5. 可以在列表前添加自然语言说明，然后紧跟格式化的列表
6. 如果只是普通聊天，不需要创建任务，则只返回自然语言回复，不要包含列表格式

**示例：**
用户："帮我拆解这个目标：学习Flutter开发"
回复："好的，我为你拆解了这个学习目标，以下是具体任务：

1. 学习Dart基础语法（截止日期：2024-12-30）[优先级：高]
2. 掌握Flutter基础组件（截止日期：2025-01-10）[优先级：高]
3. 学习状态管理（截止日期：2025-01-20）[优先级：中]
4. 完成一个实战项目（截止日期：2025-01-30）[优先级：高]"''';

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

