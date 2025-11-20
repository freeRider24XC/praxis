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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pendingExtraction = null;
    });

    final fullMessage = _selectedTag != null
        ? '[$_selectedTag] $message'
        : message;
    
    _messageController.clear();
    _selectedTag = null;

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
      
      Get.back();
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
              child: SingleChildScrollView(
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
                      child: Stack(
                        children: [
                          // 大号输入框
                          TextField(
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
                          
                          // 光标模拟（可选）
                          if (_messageController.text.isEmpty)
                            Positioned(
                              left: 300,
                              top: 8,
                              child: Container(
                                width: 2,
                                height: 32,
                                color: DesignTokens.primaryColor,
                              ),
                            ),
                        ],
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
              ),
            ),

            // 底部输入栏
            Container(
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
                      // 语音输入按钮
                      Container(
                        width: 48,
                        height: 48,
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
                          Icons.mic,
                          color: isDark
                              ? DesignTokens.textSecondaryDark
                              : DesignTokens.textSecondaryLight,
                        ),
                      ),
                      
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
            ),
          ],
        ),
      ),
    );
  }
}

