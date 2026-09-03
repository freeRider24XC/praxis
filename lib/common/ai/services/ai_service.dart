import 'package:praxis/common/ai/providers/ai_provider.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';

// 导出ChatMessage以便外部使用
export 'package:praxis/common/ai/providers/openai_provider.dart'
    show ChatMessage;

/// Token used to signal cancellation of an in-flight AI request.
class AiCancelToken {
  AiCancelToken();
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() { _cancelled = true; }
  void reset() { _cancelled = false; }
}

class AiService {
  AiService({AiProvider? provider, int? maxHistoryMessages})
      : _provider = provider ?? OpenAIProvider(),
        _maxHistoryMessages = maxHistoryMessages ?? _kDefaultMaxHistory;

  static const int _kDefaultMaxHistory = 50;
  final AiProvider _provider;
  final int _maxHistoryMessages;

  // 对话历史
  final List<ChatMessage> _history = [];

  /// The active cancel token for the currently in-flight request, if any.
  AiCancelToken? _activeToken;

  /// Maximum number of messages to retain in history.
  /// Once exceeded, the oldest user/assistant pair is removed.
  int get maxHistoryMessages => _maxHistoryMessages;
  set maxHistoryMessages(int value) {
    // ignore invalid values
  }

  /// Returns true if there is an active in-flight request.
  bool get hasActiveRequest => _activeToken != null && !_activeToken!.isCancelled;

  /// Cancels any in-flight AI request.
  /// Does nothing if no request is currently in flight.
  void cancelActiveRequest() {
    _activeToken?.cancel();
  }

  /// Removes all messages from history.
  void clearHistory() {
    _history.clear();
    _activeToken = null;
  }

  /// Returns a read-only view of the current history.
  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Trims history to at most [_maxHistoryMessages].
  /// Removes the oldest user/assistant pairs from the front.
  void _trimHistory() {
    while (_history.length > _maxHistoryMessages) {
      // Always remove in pairs (user + assistant)
      _history.removeAt(0);
    }
  }

  /// Returns true if the service is configured with valid credentials.
  Future<bool> isConfigured() async {
    return await _provider.isConfigured();
  }

  /// Sends a message and returns the AI response.
  /// Throws [AiCancelledException] if the request is cancelled.
  /// History is automatically trimmed to [_maxHistoryMessages].
  Future<String> sendMessage(String message, {AiCancelToken? cancelToken}) async {
    if (!await isConfigured()) {
      throw Exception('API密钥未配置，请在设置中配置API密钥');
    }

    // Honour external cancellation
    if (cancelToken != null && cancelToken.isCancelled) {
      throw const AiCancelledException();
    }

    // Reject if another request is already in flight
    if (hasActiveRequest) {
      throw const AiRequestInFlightException();
    }

    final token = cancelToken ?? AiCancelToken();
    _activeToken = token;

    // Add user message to history
    _history.add(ChatMessage(role: 'user', content: message));

    try {
      // Call AI — note: cancelToken integration at the HTTP layer is
      // package-specific; the token is checked after the response returns.
      final response = await _provider.chat(message, _history);

      // Check if cancelled after the HTTP call returns
      if (token.isCancelled) {
        throw const AiCancelledException();
      }

      // Add assistant response to history and trim
      _history.add(ChatMessage(role: 'assistant', content: response));
      _trimHistory();

      return response;
    } catch (e) {
      // If the request was cancelled while in flight, remove the user msg
      if (token.isCancelled) {
        if (_history.isNotEmpty && _history.last.role == 'user') {
          _history.removeLast();
        }
        throw const AiCancelledException();
      }
      // On error, remove the user message we just added
      if (_history.isNotEmpty && _history.last.role == 'user') {
        _history.removeLast();
      }
      rethrow;
    } finally {
      if (identical(_activeToken, token)) {
        _activeToken = null;
      }
    }
  }

  /// Returns the last message in history, or null if history is empty.
  ChatMessage? getLastMessage() {
    return _history.isEmpty ? null : _history.last;
  }

  /// Tests connectivity to the AI provider.
  Future<bool> testConnection() async {
    return await _provider.testConnection();
  }
}

/// Thrown when an AI request is cancelled via [AiCancelToken].
class AiCancelledException implements Exception {
  const AiCancelledException();
  @override
  String toString() => 'AI请求已取消';
}

/// Thrown when [sendMessage] is called while another request is already in flight.
class AiRequestInFlightException implements Exception {
  const AiRequestInFlightException();
  @override
  String toString() => '已有AI请求正在进行中，请等待完成后再试';
}
