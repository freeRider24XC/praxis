import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/ai/services/ai_service.dart';
import 'package:praxis/common/ai/providers/openai_provider.dart';
import 'package:praxis/common/ai/parsers/entity_extractor.dart';
import 'package:praxis/common/services/database_service.dart';
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
        if (extraction.hasTodo || extraction.hasGoal || extraction.hasTodos) {
          _pendingExtraction = extraction;
        }
      });

      // 滚动到底部
      _scrollToBottom();
    } catch (e) {
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
        Get.snackbar('成功', '待办事项已创建', snackPosition: SnackPosition.BOTTOM);
      } else if (_pendingExtraction!.hasGoal && _pendingExtraction!.goal != null) {
        await DatabaseService.addGoal(_pendingExtraction!.goal!);
        Get.snackbar('成功', '目标已创建', snackPosition: SnackPosition.BOTTOM);
      } else if (_pendingExtraction!.hasTodos && _pendingExtraction!.todos != null) {
        await DatabaseService.addTodos(_pendingExtraction!.todos!);
        Get.snackbar('成功', '已创建${_pendingExtraction!.todos!.length}个待办事项', snackPosition: SnackPosition.BOTTOM);
      }

      setState(() {
        _pendingExtraction = null;
      });
    } catch (e) {
      Get.snackbar('错误', '创建失败: $e', snackPosition: SnackPosition.BOTTOM);
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

          // 待确认的实体卡片（使用 Flexible 防止溢出）
          if (_pendingExtraction != null)
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: _buildConfirmationCard(),
                ),
              ),
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
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildLoadingMessage();
        }
        return _buildMessageItem(messages[index]);
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.smart_toy, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.blue.shade900 : Colors.grey.shade900,
                ),
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

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.smart_toy, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 40,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard() {
    if (_pendingExtraction!.hasTodos && _pendingExtraction!.todos != null) {
      // 多个任务的情况
      return Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '创建${_pendingExtraction!.todos!.length}个待办事项',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${index + 1}. ${todo.title}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
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
                          fontSize: 12,
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
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _confirmCreate,
                  child: const Text('确认创建全部'),
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
          Row(
            children: [
              Chip(
                label: Text(todo.priority.displayName),
                backgroundColor: _getPriorityColor(todo.priority),
              ),
              if (todo.dueDate != null) ...[
                const SizedBox(width: 8),
                Text(
                  '截止: ${_formatDate(todo.dueDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
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
          Row(
            children: [
              Chip(
                label: Text(goal.type.displayName),
                backgroundColor: Colors.purple.shade100,
              ),
              const SizedBox(width: 8),
              Text(
                '目标日期: ${_formatDate(goal.targetDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      );
    } else {
      title = '创建任务';
      content = const Text('未知类型');
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
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
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _confirmCreate,
                child: const Text('确认创建'),
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

