import 'package:flutter/material.dart';
import 'package:praxis/common/ai/services/ai_service.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/ai/parsers/entity_extractor.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/widgets/praxis_card.dart';
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: DesignTokens.primaryColor.withOpacity(0.1),
              child: Icon(Icons.smart_toy, color: DesignTokens.primaryColor),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: PraxisCard(
              padding: const EdgeInsets.all(DesignTokens.spacing3),
              color: isUser ? DesignTokens.primaryColor.withOpacity(0.1) : null,
              showShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.blue.shade900 : Colors.grey.shade900,
                    ),
                  ),
                  // 如果是AI消息且显示待办列表，添加待办事项卡片
                  if (showTodoList && _pendingExtraction != null) ...[
                    const SizedBox(height: 12),
                    _buildTodoListInMessage(),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, color: Colors.blue),
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
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.blue.shade700, size: 18),
                const SizedBox(width: 8),
                Text(
                  '待办事项列表（${_pendingExtraction!.todos!.length}个）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...(_pendingExtraction!.todos!.asMap().entries.map((entry) {
              final index = entry.key;
              final todo = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${todo.title}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            todo.priority.displayName,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: _getPriorityColor(todo.priority),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    if (todo.description != null && todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    if (todo.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '截止日期: ${_formatDate(todo.dueDate!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            })),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _pendingExtraction = null),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _confirmCreate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  '截止: ${_formatDate(todo.dueDate!)}',
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
                '目标日期: ${_formatDate(goal.targetDate)}',
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
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _pendingExtraction = null),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('取消', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _confirmCreate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
          ),
        ],
      ),
    );
  }
}

