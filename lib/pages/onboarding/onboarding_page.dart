import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/main/main_page.dart';
import 'package:get/get.dart';

/// 启动页
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (mounted) {
      Get.offAll(() => const MainPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: DesignTokens.backgroundDark,
        ),
        child: Stack(
          children: [
            // 动态背景渐变
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  color: DesignTokens.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.3 * _fadeAnimation.value,
                      child: Transform.scale(
                        scale: 1.0 + (_controller.value * 0.2),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5,
              left: MediaQuery.of(context).size.width * 0.5,
              child: Transform.translate(
                offset: const Offset(-150, -150),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: DesignTokens.secondaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.2 * _fadeAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.secondaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: DesignTokens.secondaryOrange,
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.2 * _fadeAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.secondaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // 内容
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing8,
                  vertical: DesignTokens.spacing10,
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    
                    // 火箭图标
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 256,
                              height: 256,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusXLarge + 8,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: -0.1,
                                child: const Icon(
                                  Icons.rocket_launch,
                                  size: 128,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 装饰图标
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: const Offset(100, -20),
                            child: Transform.rotate(
                              angle: 0.2,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      DesignTokens.primaryColor,
                                      DesignTokens.secondaryPurple,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusXLarge,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    // 标题和描述
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: DesignTokens.textStyle(
                                  fontSize: 36,
                                  fontWeight: DesignTokens.fontWeightBold,
                                  color: Colors.white,
                                ),
                                children: [
                                  const TextSpan(text: '把梦想\n'),
                                  const TextSpan(text: '拆解为'),
                                  TextSpan(
                                    text: '现实',
                                    style: TextStyle(
                                      foreground: Paint()
                                        ..shader = LinearGradient(
                                          colors: const [
                                            Color(0xFF818CF8), // Indigo-400
                                            Color(0xFFEC4899), // Pink-500
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 70),
                                        ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: DesignTokens.spacing4),
                            Text(
                              '一句话描述目标，AI 为你生成每一步执行路径。',
                              style: DesignTokens.textStyle(
                                fontSize: DesignTokens.fontSizeBodyLarge,
                                fontWeight: DesignTokens.fontWeightMedium,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: DesignTokens.spacing12),
                    
                    // 开始按钮
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleStart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: DesignTokens.backgroundDark,
                              padding: const EdgeInsets.symmetric(
                                vertical: DesignTokens.spacing4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusXLarge,
                                ),
                              ),
                              elevation: 0,
                              shadowColor: Colors.white.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '开始探索',
                                  style: DesignTokens.textStyle(
                                    fontSize: DesignTokens.fontSizeBodyLarge,
                                    fontWeight: DesignTokens.fontWeightBold,
                                    color: DesignTokens.backgroundDark,
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.spacing2),
                                Icon(
                                  Icons.arrow_forward,
                                  color: DesignTokens.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: DesignTokens.spacing8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 检查是否需要显示启动页
class OnboardingChecker {
  static const String _key = 'has_seen_onboarding';

  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }
}

