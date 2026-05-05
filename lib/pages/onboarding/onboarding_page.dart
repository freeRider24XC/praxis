import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';
import 'package:praxis/pages/ai_chat/ai_plan_page.dart';
import 'package:praxis/pages/main/main_page.dart';

/// MVP 启动引导
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _goalController = TextEditingController();
  int _step = 0;
  String? _focusedDomainId;
  int _weeklyCapacityHours = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingChecker.key, true);
    if (_focusedDomainId != null) {
      await DomainService.setFocusedDomain(_focusedDomainId!);
    }
    await ProfileService.updateWeeklyCapacity(_weeklyCapacityHours);
    if (!mounted) return;
    Get.offAll(() => const MainPage());
  }

  Future<void> _goToPlanning() async {
    if (_goalController.text.trim().isEmpty || _focusedDomainId == null) {
      return;
    }

    await DomainService.setFocusedDomain(_focusedDomainId!);
    await ProfileService.updateWeeklyCapacity(_weeklyCapacityHours);

    final result = await Get.to<bool>(
      () => AiPlanPage(initialGoalText: _goalController.text.trim()),
    );

    if (result == true) {
      await _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: DesignTokens.backgroundDark,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing8,
              vertical: DesignTokens.spacing8,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DesignTokens.spacing6),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Text(
                      _titleForStep(),
                      style: DesignTokens.textStyle(
                        fontSize: 34,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing4),
                    Text(
                      _subtitleForStep(),
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodyLarge,
                        color: Colors.white.withOpacity(0.74),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Expanded(
                      child: _buildStepContent(),
                    ),
                    const SizedBox(height: DesignTokens.spacing6),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _primaryActionEnabled() ? _onPrimaryAction : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: DesignTokens.backgroundDark,
                          padding: const EdgeInsets.symmetric(
                            vertical: DesignTokens.spacing4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                          ),
                        ),
                        child: Text(
                          _step == 2 ? '进入 AI 拆解' : '继续',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodyLarge,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: DesignTokens.backgroundDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing3),
                    if (_step > 0)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _step -= 1;
                            });
                          },
                          child: Text(
                            '返回上一步',
                            style: DesignTokens.textStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleForStep() {
    switch (_step) {
      case 0:
        return '先选一个\n当前重点方向';
      case 1:
        return '写下你想推进的\n一个目标';
      case 2:
      default:
        return '给自己一个\n现实节奏';
    }
  }

  String _subtitleForStep() {
    switch (_step) {
      case 0:
        return '先只盯住一个领域，别把第一周做复杂。';
      case 1:
        return '一句话就够，AI 会帮你把它拆成这一周的行动。';
      case 2:
      default:
        return '选择你这周大概能投入的时间，让计划更贴近现实。';
    }
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        final domains = DomainService.getDomains();
        return Wrap(
          spacing: DesignTokens.spacing3,
          runSpacing: DesignTokens.spacing3,
          children: domains.map((LifeDomain domain) {
            final selected = domain.id == _focusedDomainId;
            return ChoiceChip(
              label: Text('${domain.icon} ${domain.name}'),
              selected: selected,
              backgroundColor: Colors.white.withOpacity(0.08),
              selectedColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? DesignTokens.backgroundDark : Colors.white,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) {
                setState(() {
                  _focusedDomainId = domain.id;
                });
              },
            );
          }).toList(),
        );
      case 1:
        return TextField(
          controller: _goalController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '例如：三个月内建立稳定健身习惯',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        );
      case 2:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Slider(
              value: _weeklyCapacityHours.toDouble(),
              min: 2,
              max: 14,
              divisions: 12,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.2),
              label: '$_weeklyCapacityHours 小时',
              onChanged: (value) {
                setState(() {
                  _weeklyCapacityHours = value.round();
                });
              },
            ),
            const SizedBox(height: DesignTokens.spacing3),
            Text(
              '$_weeklyCapacityHours 小时 / 周',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeTitleLarge,
                fontWeight: DesignTokens.fontWeightBold,
                color: Colors.white,
              ),
            ),
          ],
        );
    }
  }

  bool _primaryActionEnabled() {
    if (_step == 0) return _focusedDomainId != null;
    if (_step == 1) return _goalController.text.trim().isNotEmpty;
    return true;
  }

  void _onPrimaryAction() {
    if (_step < 2) {
      setState(() {
        _step += 1;
      });
    } else {
      _goToPlanning();
    }
  }
}

class OnboardingChecker {
  static const String key = 'has_seen_onboarding';

  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(key) ?? false);
  }
}
