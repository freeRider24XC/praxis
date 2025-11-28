import 'dart:async';
import 'package:flutter/material.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/models/focus_session.dart';
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
  String? _selectedSound;
  bool _soundEnabled = false;
  DateTime? _sessionStartTime;
  int _pausedDuration = 0; // 暂停的总时长（秒）
  DateTime? _pauseStartTime;
  
  final List<Map<String, dynamic>> _soundOptions = [
    {'name': '无', 'icon': Icons.volume_off, 'value': null},
    {'name': '雨声', 'icon': Icons.water_drop, 'value': 'rain'},
    {'name': '海浪', 'icon': Icons.waves, 'value': 'ocean'},
    {'name': '森林', 'icon': Icons.forest, 'value': 'forest'},
    {'name': '咖啡厅', 'icon': Icons.local_cafe, 'value': 'cafe'},
    {'name': '白噪音', 'icon': Icons.graphic_eq, 'value': 'white'},
  ];

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
      
      // 记录开始时间（首次启动时）
      if (_sessionStartTime == null) {
        _sessionStartTime = DateTime.now();
      }
      
      // 如果是从暂停恢复，计算暂停时长
      if (_pauseStartTime != null) {
        _pausedDuration += DateTime.now().difference(_pauseStartTime!).inSeconds;
        _pauseStartTime = null;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer(completed: true);
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = true;
      _pauseStartTime = DateTime.now();
    });
    _timer?.cancel();
  }

  void _stopTimer({bool completed = false}) {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
    _timer?.cancel();
    
    // 如果倒计时完成，记录专注会话
    if (completed && _sessionStartTime != null) {
      _recordFocusSession(completed: true);
    }
    
    // 重置会话状态
    _sessionStartTime = null;
    _pausedDuration = 0;
    _pauseStartTime = null;
  }
  
  Future<void> _recordFocusSession({required bool completed}) async {
    if (_sessionStartTime == null) return;
    
    final endTime = DateTime.now();
    // 计算实际专注时长（总时长 - 暂停时长）
    final actualDuration = _totalSeconds - _pausedDuration;
    
    // 只记录至少完成一半的会话
    if (actualDuration < _totalSeconds ~/ 2) {
      return;
    }
    
    final session = FocusSession(
      startTime: _sessionStartTime!,
      endTime: endTime,
      duration: actualDuration,
      taskTitle: widget.taskTitle,
      completed: completed,
    );
    
    try {
      await DatabaseService.addFocusSession(session);
    } catch (e) {
      debugPrint('记录专注会话失败: $e');
    }
  }

  void _skipTimer() {
    _stopTimer(completed: false);
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
                    onTap: _showSoundSelector,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _soundEnabled
                            ? DesignTokens.primaryColor.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _soundEnabled ? Icons.volume_up : Icons.volume_off,
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

  void _showSoundSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusXLarge),
            topRight: Radius.circular(DesignTokens.radiusXLarge),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: DesignTokens.spacing3),
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacing6),
                child: Column(
                  children: [
                    Text(
                      '背景音效',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeHeadlineSmall,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing6),
                    ..._soundOptions.map((sound) {
                      final isSelected = _selectedSound == sound['value'];
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (sound['value'] == null) {
                              _soundEnabled = false;
                              _selectedSound = null;
                            } else {
                              _soundEnabled = true;
                              _selectedSound = sound['value'] as String;
                            }
                          });
                          Get.back();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
                          padding: const EdgeInsets.all(DesignTokens.spacing4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? DesignTokens.primaryColor.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                            border: Border.all(
                              color: isSelected
                                  ? DesignTokens.primaryColor
                                  : Colors.white.withOpacity(0.1),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? DesignTokens.primaryColor.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                                ),
                                child: Icon(
                                  sound['icon'] as IconData,
                                  color: isSelected
                                      ? DesignTokens.primaryColor
                                      : Colors.white.withOpacity(0.7),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: DesignTokens.spacing4),
                              Expanded(
                                child: Text(
                                  sound['name'] as String,
                                  style: DesignTokens.textStyle(
                                    fontSize: DesignTokens.fontSizeBodyMedium,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  color: DesignTokens.primaryColor,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
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

