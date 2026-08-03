import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:praxis/common/ai/services/ai_use_case_service.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/app_runtime_service.dart';

class ManagedAiService {
  const ManagedAiService();

  bool get isConfigured => AppRuntimeService.isManagedAiConfigured;

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (AppRuntimeService.managedAiToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${AppRuntimeService.managedAiToken}';
    }
    return headers;
  }

  Uri _uri(String path) {
    final base = AppRuntimeService.managedAiBaseUrl.replaceFirst(RegExp(r'/$'), '');
    return Uri.parse('$base$path');
  }

  Future<AiGoalPlanDraft> planGoal({
    required String goalText,
    required String focusedDomainId,
    required int weeklyCapacityHours,
  }) async {
    final response = await http.post(
      _uri('/plan-goal'),
      headers: _headers(),
      body: jsonEncode({
        'goalText': goalText,
        'focusedDomainId': focusedDomainId,
        'weeklyCapacityHours': weeklyCapacityHours,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Managed AI request failed: ${response.statusCode}');
    }

    return AiSchemaParser.parseGoalPlan(
      response.body,
      fallbackDomainId: focusedDomainId,
    );
  }

  Future<AiReviewFeedback> reviewDay({
    required DailyReview review,
  }) async {
    final response = await http.post(
      _uri('/review-day'),
      headers: _headers(),
      body: jsonEncode({
        'whatDone': review.whatDone,
        'blockers': review.blockers,
        'topPriorityTomorrow': review.topPriorityTomorrow,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Managed AI request failed: ${response.statusCode}');
    }

    return AiSchemaParser.parseReviewFeedback(response.body);
  }

  Future<AiSuggestionResult> suggestToday({
    required String? focusedDomainName,
    required List<Todo> todos,
  }) async {
    final response = await http.post(
      _uri('/suggest-today'),
      headers: _headers(),
      body: jsonEncode({
        'focusedDomain': focusedDomainName,
        'todos': todos
            .map((todo) => {
                  'title': todo.title,
                  'description': todo.description,
                  'priority': todo.priority.name,
                  'dueDate': todo.dueDate?.toIso8601String(),
                })
            .toList(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Managed AI request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AiSuggestionResult(
      content: (decoded['suggestion'] as String?)?.trim() ?? '',
      isMock: false,
    );
  }
}
