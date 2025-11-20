import 'dart:async';
import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:get/get.dart';

/// 专注模式页
class FocusPage extends StatefulWidget {
  final String? taskTitle;
  
  const FocusPage({
    super.key,
    this.taskTitle,
  });

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  Timer? _timer;
  int _totalSeconds = 25 * 60; // 25分钟
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) {
      _pauseTimer();
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
    _timer?.cancel();
  }

  void _skipTimer() {
    _stopTimer();
    // 可以跳转到下一个任务
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    return 1.0 - (_remainingSeconds / _totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacing3,
                      vertical: DesignTokens.spacing1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'FOCUS',
                      style: DesignTokens.textStyle(
                        fontSize: 10,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 白噪音控制
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 主要内容
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 呼吸灯效果
                    Container(
                      width: 288,
                      height: 288,
                      decoration: BoxDecoration(
                        color: DesignTokens.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    
                    const SizedBox(height: -288),
                    
                    // 圆形进度条
                    SizedBox(
                      width: 288,
                      height: 288,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 进度圆环
                          SizedBox(
                            width: 288,
                            height: 288,
                            child: CircularProgressIndicator(
                              value: _getProgress(),
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.shade900,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DesignTokens.primaryColor,
                              ),
                            ),
                          ),
                          
                          // 时间显示
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(_remainingSeconds),
                                style: DesignTokens.textStyle(
                                  fontSize: 56,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: DesignTokens.spacing1),
                              Text(
                                'Remaining',
                                style: DesignTokens.textStyle(
                                  fontSize: DesignTokens.fontSizeLabelSmall,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: DesignTokens.primaryColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: DesignTokens.spacing16),
                    
                    // 当前任务
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spacing2),
                        Text(
                          'Doing Now',
                          style: DesignTokens.textStyle(
                            fontSize: 10,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: DesignTokens.spacing4),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing8,
                      ),
                      child: Text(
                        widget.taskTitle ?? '深度工作：核心代码实现',
                        textAlign: TextAlign.center,
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeHeadlineSmall,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 控制按钮
            Padding(
              padding: const EdgeInsets.only(
                bottom: DesignTokens.spacing16,
                left: DesignTokens.spacing10,
                right: DesignTokens.spacing10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 停止
                  _buildControlButton(
                    icon: Icons.stop,
                    onPressed: _stopTimer,
                  ),
                  
                  // 暂停/继续
                  _buildControlButton(
                    icon: _isPaused ? Icons.play_arrow : Icons.pause,
                    isPrimary: true,
                    onPressed: _startTimer,
                  ),
                  
                  // 跳过
                  _buildControlButton(
                    icon: Icons.skip_next,
                    onPressed: _skipTimer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isPrimary ? 96 : 64,
        height: isPrimary ? 96 : 64,
        decoration: BoxDecoration(
          color: isPrimary
              ? DesignTokens.primaryColor
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isPrimary ? DesignTokens.radiusXLarge : DesignTokens.radiusRound),
          border: isPrimary
              ? Border.all(
                  color: DesignTokens.primaryDark,
                  width: 4,
                )
              : Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: DesignTokens.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 32 : 24,
        ),
      ),
    );
  }
}

