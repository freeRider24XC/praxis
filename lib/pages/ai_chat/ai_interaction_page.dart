import 'package:flutter/material.dart';
import 'package:praxis/common/ai/services/ai_service.dart';
import 'package:praxis/common/ai/parsers/entity_extractor.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/error_service.dart';
import 'package:praxis/common/services/logger_service.dart';
import 'package:praxis/common/widgets/tag_chip.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:get/get.dart';

/// AI交互页（按设计稿重构）
class AiInteractionPage extends StatefulWidget {
  const AiInteractionPage({super.key});

  @override
  State<AiInteractionPage> createState() => _AiInteractionPageState();
}

class _AiInteractionPageState extends State<AiInteractionPage> {
  final AiService _aiService = AiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  String? _errorMessage;
  EntityExtractionResult? _pendingExtraction;
  String? _selectedTag;
  bool _isChatMode = false; // 是否进入对话模式

  final List<Map<String, dynamic>> _tags = [
    {'label': '🏃‍♂️ 运动健身', 'value': 'fitness'},
    {'label': '📚 技能学习', 'value': 'study'},
    {'label': '✈️ 旅行规划', 'value': 'travel'},
  ];

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

    // 如果是第一次发送消息，切换到对话模式
    if (!_isChatMode) {
      setState(() {
        _isChatMode = true;
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pendingExtraction = null;
    });

    final fullMessage = _selectedTag != null && !_isChatMode
        ? '[$_selectedTag] $message'
        : message;
    
    _messageController.clear();
    if (!_isChatMode) {
      _selectedTag = null;
    }

    try {
      final response = await _aiService.sendMessage(fullMessage);
      
      // 尝试提取实体
      final extraction = EntityExtractor.extractFromResponse(response);
      
      setState(() {
        _isLoading = false;
        if (extraction.hasTodo || extraction.hasGoal || extraction.hasTodos) {
          _pendingExtraction = extraction;
        }
      });

      _scrollToBottom();
    } catch (e) {
      LoggerService.error('发送AI消息失败', 'AiInteractionPage', e);
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
      LoggerService.error('创建实体失败', 'AiInteractionPage', e);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing6,
                vertical: DesignTokens.spacing4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DesignTokens.surfaceDarkSecondary
                            : DesignTokens.surfaceLightSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? DesignTokens.borderDark
                              : DesignTokens.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: isDark
                            ? DesignTokens.textSecondaryDark
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 内容区域
            Expanded(
              child: _isChatMode
                  ? _buildChatView(isDark)
                  : _buildInputView(isDark),
            ),

            // 底部输入栏
            _isChatMode
                ? _buildChatInputArea(isDark)
                : _buildInitialInputArea(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInputView(bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI图标
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primaryColor,
                  DesignTokens.secondaryPurple,
                ],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
              boxShadow: DesignTokens.shadowFloat,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(height: DesignTokens.spacing8),
          
          // 标题
          RichText(
            text: TextSpan(
              style: DesignTokens.textStyle(
                fontSize: 36,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
              children: [
                const TextSpan(text: '你想达成什么\n'),
                TextSpan(
                  text: '新目标？',
                  style: TextStyle(
                    color: DesignTokens.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignTokens.spacing4),
          
          // 描述
          Text(
            '告诉我你的想法，我会帮你拆解成可执行的小步骤。',
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeBodyLarge,
              fontWeight: DesignTokens.fontWeightMedium,
              color: isDark
                  ? DesignTokens.textSecondaryDark
                  : DesignTokens.textSecondaryLight,
            ),
          ),
          
          const SizedBox(height: DesignTokens.spacing10),
          
          // 输入区域
          Container(
            constraints: const BoxConstraints(
              minHeight: 192,
            ),
            child: TextField(
              controller: _messageController,
              maxLines: null,
              style: DesignTokens.textStyle(
                fontSize: 28,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
              decoration: InputDecoration(
                hintText: '例如：我想在一个月内减重 5 斤...',
                hintStyle: DesignTokens.textStyle(
                  fontSize: 28,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: isDark
                      ? DesignTokens.textTertiaryDark
                      : DesignTokens.textTertiaryLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          const SizedBox(height: DesignTokens.spacing4),
          
          // 标签选择器
          Wrap(
            spacing: DesignTokens.spacing3,
            runSpacing: DesignTokens.spacing3,
            children: _tags.map((tag) {
              final isSelected = _selectedTag == tag['value'];
              return TagChip(
                label: tag['label'] as String,
                style: TagChipStyle.neutral,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedTag = isSelected ? null : tag['value'] as String;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView(bool isDark) {
    final messages = _aiService.history;
    
    if (messages.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.primaryColor,
                    DesignTokens.secondaryPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing6),
            Text(
              '开始与AI对话',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeTitleLarge,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing2),
            Text(
              '我可以帮你拆解目标、制定任务、安排日程',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeBodyMedium,
                color: isDark
                    ? DesignTokens.textSecondaryDark
                    : DesignTokens.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      itemCount: messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return Padding(
            padding: const EdgeInsets.all(DesignTokens.spacing4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesignTokens.primaryColor,
                        DesignTokens.secondaryPurple,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacing3),
                Text(
                  'AI正在思考...',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyMedium,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        }
        
        final message = messages[index];
        final isLastAiMessage = index == messages.length - 1 && 
                                 message.role == 'assistant' &&
                                 _pendingExtraction != null;
        return _buildChatMessageItem(message, isDark, showExtraction: isLastAiMessage);
      },
    );
  }

  Widget _buildChatMessageItem(ChatMessage message, bool isDark, {bool showExtraction = false}) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacing6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.primaryColor,
                    DesignTokens.secondaryPurple,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing3),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(DesignTokens.spacing4),
                  decoration: BoxDecoration(
                    color: isUser
                        ? DesignTokens.primaryColor
                        : (isDark
                            ? DesignTokens.surfaceDark
                            : DesignTokens.surfaceLightSecondary),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(DesignTokens.radiusXLarge),
                      topRight: const Radius.circular(DesignTokens.radiusXLarge),
                      bottomLeft: Radius.circular(isUser ? DesignTokens.radiusXLarge : DesignTokens.radiusSmall),
                      bottomRight: Radius.circular(isUser ? DesignTokens.radiusSmall : DesignTokens.radiusXLarge),
                    ),
                    border: !isUser ? Border.all(
                      color: isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight,
                      width: 0.5,
                    ) : null,
                  ),
                  child: Text(
                    message.content,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyMedium,
                      color: isUser
                          ? Colors.white
                          : (isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight),
                    ),
                  ),
                ),
                // 如果是AI消息且显示提取结果，添加确认卡片
                if (showExtraction && _pendingExtraction != null) ...[
                  const SizedBox(height: DesignTokens.spacing3),
                  _buildExtractionCard(isDark),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: DesignTokens.spacing3),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DesignTokens.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: DesignTokens.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExtractionCard(bool isDark) {
    if (_pendingExtraction == null) return const SizedBox.shrink();
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.surfaceDark
            : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: DesignTokens.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: DesignTokens.shadowIOS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: DesignTokens.primaryColor,
                size: 20,
              ),
              const SizedBox(width: DesignTokens.spacing2),
              Text(
                _pendingExtraction!.hasTodos 
                    ? '待办事项'
                    : (_pendingExtraction!.hasGoal ? '目标' : '待办事项'),
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: DesignTokens.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing3),
          if (_pendingExtraction!.hasTodos && _pendingExtraction!.todos != null) ...[
            ..._pendingExtraction!.todos!.take(3).map((todo) {
              return Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacing2),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                    const SizedBox(width: DesignTokens.spacing2),
                    Expanded(
                      child: Text(
                        todo.title,
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeBodySmall,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (_pendingExtraction!.todos!.length > 3)
              Text(
                '还有 ${_pendingExtraction!.todos!.length - 3} 个任务...',
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeLabelSmall,
                  color: isDark
                      ? DesignTokens.textSecondaryDark
                      : DesignTokens.textSecondaryLight,
                ),
              ),
          ] else if (_pendingExtraction!.hasTodo && _pendingExtraction!.todo != null) ...[
            Text(
              _pendingExtraction!.todo!.title,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeBodyMedium,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
          ] else if (_pendingExtraction!.hasGoal && _pendingExtraction!.goal != null) ...[
            Text(
              _pendingExtraction!.goal!.title,
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeBodyMedium,
                fontWeight: DesignTokens.fontWeightBold,
                color: isDark
                    ? DesignTokens.onSurfaceDark
                    : DesignTokens.onSurfaceLight,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.spacing4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _pendingExtraction = null;
                  });
                },
                child: Text(
                  '取消',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodySmall,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spacing2),
              ElevatedButton(
                onPressed: _confirmCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing4,
                    vertical: DesignTokens.spacing2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  ),
                ),
                child: Text(
                  '确认创建',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodySmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing6),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.backgroundDark
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? DesignTokens.borderDark
                : DesignTokens.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              // 字符计数
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing2,
                  vertical: DesignTokens.spacing1,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignTokens.surfaceDarkSecondary
                      : DesignTokens.surfaceLightSecondary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                child: Text(
                  '${_messageController.text.length}/200',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.textTertiaryDark
                        : DesignTokens.textTertiaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing4),
          // 开始智能规划按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? DesignTokens.surfaceDark
                    : Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: DesignTokens.spacing5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge - 4),
                ),
                elevation: 0,
                shadowColor: DesignTokens.primaryColor.withOpacity(0.2),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: DesignTokens.spacing2),
                        Text(
                          '开始智能规划',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodyLarge,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark
            ? DesignTokens.backgroundDark
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? DesignTokens.borderDark
                : DesignTokens.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? DesignTokens.surfaceDarkSecondary
                    : DesignTokens.surfaceLightSecondary,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                border: Border.all(
                  color: isDark
                      ? DesignTokens.borderDark
                      : DesignTokens.borderLight,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                style: DesignTokens.textStyle(
                  fontSize: DesignTokens.fontSizeBodyMedium,
                  color: isDark
                      ? DesignTokens.onSurfaceDark
                      : DesignTokens.onSurfaceLight,
                ),
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyMedium,
                    color: isDark
                        ? DesignTokens.textTertiaryDark
                        : DesignTokens.textTertiaryLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacing4,
                    vertical: DesignTokens.spacing3,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spacing3),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignTokens.primaryColor,
                  DesignTokens.secondaryPurple,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

