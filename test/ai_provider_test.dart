import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/ai/services/ai_config_service.dart';
import 'package:praxis/common/services/secure_storage_service.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this.responses);
  final List<http.Response> responses;
  var calls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = responses[calls++];
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

class _FakeSecureStorage extends SecureStorageService {
  _FakeSecureStorage(this.apiKey);
  final String apiKey;

  @override
  Future<SecureStorageResult<String?>> read(String key) async {
    return SecureReadOk<String?>(apiKey);
  }

  @override
  Future<SecureStorageResult<void>> write(String key, String value) async {
    return const SecureWriteOk();
  }
}

void main() {
  setUp(() async {
    await initializeDateFormatting('zh_CN');
    AiConfigService.testSecureOverride = _FakeSecureStorage('test-key');
  });

  tearDown(() {
    AiConfigService.testSecureOverride = null;
  });

  test('retries rate limits and returns the eventual response', () async {
    final client = _FakeClient([
      http.Response('busy', 429),
      http.Response('busy', 503),
      http.Response(
        '{"choices":[{"message":{"content":"ok"}}]}',
        200,
      ),
    ]);

    final result = await OpenAIProvider(client: client).chat('hello', const []);

    expect(result, 'ok');
    expect(client.calls, 3);
  });

  test('does not retry authentication failures', () async {
    final client = _FakeClient([http.Response('unauthorized', 401)]);

    await expectLater(
      OpenAIProvider(client: client).chat('hello', const []),
      throwsA(predicate((error) => error.toString().contains('API密钥无效'))),
    );
    expect(client.calls, 1);
    expect(await AiConfigService.isConfigured(), isTrue);
  });
}
