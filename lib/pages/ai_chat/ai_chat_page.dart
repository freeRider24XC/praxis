import 'package:flutter/material.dart';
import 'package:praxis/common/ai/services/ai_service.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/ai/parsers/entity_extractor.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/widgets/loading_indicator.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/models/todo.dart';
import 'package:praxis/common/models/goal.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final AiService _aiService = AiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  String? _errorMessage;
  EntityExtractionResult? _pendingExtraction;

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  Future<void> _checkConfiguration() async {
    if (!await _aiService.isConfigured()) {
      setState(() {
        _errorMessage = '请先在设置中配置API密钥';
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pendingExtraction = null;
    });

    _messageController.clear();

    try {
      final response = await _aiService.sendMessage(message);
      
      // 尝试提取实体
      final extraction = EntityExtractor.extractFromResponse(response);
      
      setState(() {
        _isLoading = false;
        // 将提取结果存储到最后一个AI消息中
        if (extraction.hasTodo || extraction.hasGoal || extraction.hasTodos) {
          _pendingExtraction = extraction;
        }
      });

      // 滚动到底部
      _scrollToBottom();
    } catch (e) {
      LoggerService.error('发送AI消息失败', 'AiChatPage', e);
      ErrorService.handleError(e, context: 'AI聊天');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _confirmCreate() async {
    if (_pendingExtraction == null) return;

    try {
      if (_pendingExtraction!.hasTodo && _pendingExtraction!.todo != null) {
        await DatabaseService.addTodo(_pendingExtraction!.todo!);
        ErrorService.showSuccess('待办事项已创建');
      } else if (_pendingExtraction!.hasGoal && _pendingExtraction!.goal != null) {
        await DatabaseService.addGoal(_pendingExtraction!.goal!);
        ErrorService.showSuccess('目标已创建');
      } else if (_pendingExtraction!.hasTodos && _pendingExtraction!.todos != null) {
        await DatabaseService.addTodos(_pendingExtraction!.todos!);
        ErrorService.showSuccess('已创建${_pendingExtraction!.todos!.length}个待办事项');
      }

      setState(() {
        _pendingExtraction = null;
      });
    } catch (e) {
      LoggerService.error('创建实体失败', 'AiChatPage', e);
      ErrorService.handleError(e, context: '创建实体');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _aiService.clearHistory();
              setState(() {
                _pendingExtraction = null;
              });
            },
            tooltip: '清除对话历史',
          ),
        ],
      ),
      body: Column(
        children: [
          // 错误提示
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _errorMessage = null),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),

          // 消息列表
          Expanded(
            child: _buildMessageList(),
          ),

          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _aiService.history;
    
    if (messages.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '开始与AI对话',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '我可以帮你拆解目标、制定任务、安排日程',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spacing4),
            child: LoadingIndicator(message: 'AI正在思考...'),
          );
        }
        // 如果是最后一个AI消息且有待办事项，显示待办列表
        final isLastAiMessage = index == messages.length - 1 && 
                                 messages[index].role == 'assistant' &&
                                 _pendingExtraction != null;
        return _buildMessageItem(messages[index], showTodoList: isLastAiMessage);
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message, {bool showTodoList = false}) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.smart_toy,
                size: 20,
                color: DesignTokens.primaryColor,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing2),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spacing3),
              decoration: BoxDecoration(
                color: isUser 
                    ? DesignTokens.primaryColor 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                  // 如果是AI消息且显示待办列表，添加待办事项卡片
                  if (showTodoList && _pendingExtraction != null) ...[
                    const SizedBox(height: DesignTokens.spacing3),
                    _buildTodoListInMessage(),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: DesignTokens.spacing2),
            CircleAvatar(
              radius: 16,
              backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 20,
                color: DesignTokens.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildTodoListInMessage() {
    if (_pendingExtraction == null) return const SizedBox.shrink();
    
    if (_pendingExtraction!.hasTodos && _pendingExtraction!.todos != null) {
      // 多个任务的情况
      return Container(
        margin: const EdgeInsets.only(top: DesignTokens.spacing2),
        padding: const EdgeInsets.all(DesignTokens.spacing3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '我为您整理了今天的待办事项:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing3),
            ...(_pendingExtraction!.todos!.map((todo) {
              return Container(
                margin: const EdgeInsets.only(bottom: DesignTokens.spacing2),
                padding: const EdgeInsets.all(DesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: null,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (todo.dueDate != null) ...[
                            const SizedBox(height: DesignTokens.spacing1),
                            Text(
                              '截止: ${_formatDueDate(todo.dueDate!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (todo.priority != TodoPriority.medium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(todo.priority),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                        ),
                        child: Text(
                          todo.priority.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            })),
            const SizedBox(height: DesignTokens.spacing3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacing2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  ),
                ),
                child: const Text('创建全部'),
              ),
            ),
          ],
        ),
      );
    }
    
    // 单个任务或目标的情况
    String title = '';
    Widget content;
    
    if (_pendingExtraction!.hasTodo && _pendingExtraction!.todo != null) {
      final todo = _pendingExtraction!.todo!;
      title = '创建待办事项';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (todo.description != null && todo.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(todo.description!),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text(todo.priority.displayName),
                backgroundColor: _getPriorityColor(todo.priority),
              ),
              if (todo.dueDate != null)
                Text(
                  '截止: ${_formatDueDate(todo.dueDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
        ],
      );
    } else if (_pendingExtraction!.hasGoal && _pendingExtraction!.goal != null) {
      final goal = _pendingExtraction!.goal!;
      title = '创建目标';
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(goal.description!),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text(goal.type.displayName),
                backgroundColor: Colors.purple.shade100,
              ),
              Text(
                '目标日期: ${_formatDueDate(goal.targetDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: DesignTokens.spacing2),
      padding: const EdgeInsets.all(DesignTokens.spacing3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: DesignTokens.primaryColor, size: 18),
              const SizedBox(width: DesignTokens.spacing2),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.primaryColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing2),
          content,
          const SizedBox(height: DesignTokens.spacing3),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _pendingExtraction = null),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing3, vertical: DesignTokens.spacing2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('取消', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: DesignTokens.spacing2),
              ElevatedButton(
                onPressed: _confirmCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing3, vertical: DesignTokens.spacing2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('确认创建', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
      case TodoPriority.urgent:
        return Colors.red.shade100;
      case TodoPriority.medium:
        return Colors.orange.shade100;
      case TodoPriority.low:
        return Colors.green.shade100;
    }
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == tomorrow) {
      return '明天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
            color: Theme.of(context).primaryColor,
            tooltip: '发送消息',
          ),
        ],
      ),
    );
  }
}

