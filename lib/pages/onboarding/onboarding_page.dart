import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardInset > 0;

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
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height:
                                        _topSpacingForStep(isKeyboardVisible),
                                  ),
                                  if (_showHeaderIcon(isKeyboardVisible)) ...[
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
                                    const SizedBox(
                                      height: DesignTokens.spacing8,
                                    ),
                                  ],
                                  Text(
                                    _titleForStep(),
                                    style: DesignTokens.textStyle(
                                      fontSize: _titleFontSizeForStep(
                                        isKeyboardVisible,
                                      ),
                                      fontWeight: DesignTokens.fontWeightBold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: DesignTokens.spacing4,
                                  ),
                                  Text(
                                    _subtitleForStep(),
                                    style: DesignTokens.textStyle(
                                      fontSize: DesignTokens.fontSizeBodyLarge,
                                      color: Colors.white.withOpacity(0.74),
                                    ),
                                  ),
                                  SizedBox(
                                    height: _contentSpacingForStep(
                                      isKeyboardVisible,
                                    ),
                                  ),
                                  _buildStepContent(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: isKeyboardVisible
                          ? DesignTokens.spacing3
                          : DesignTokens.spacing5,
                    ),
                    AnimatedPadding(
                      duration: DesignTokens.durationFast,
                      curve: Curves.easeOut,
                      padding: EdgeInsets.only(
                        bottom: isKeyboardVisible
                            ? keyboardInset + DesignTokens.spacing2
                            : DesignTokens.spacing2,
                      ),
                      child: _buildBottomActions(),
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
        return '先写下这一阶段\n最重要的目标';
      case 2:
      default:
        return '再给这周一个\n现实节奏';
    }
  }

  String _subtitleForStep() {
    switch (_step) {
      case 0:
        return '先只盯住一个领域，别把第一周做复杂。';
      case 1:
        return '先定结果，再把它拆成项目和事项。';
      case 2:
      default:
        return '选择你这周大概能投入的时间，让拆解更贴近现实。';
    }
  }

  bool _showHeaderIcon(bool isKeyboardVisible) {
    if (isKeyboardVisible) return false;
    return _step != 1;
  }

  double _topSpacingForStep(bool isKeyboardVisible) {
    if (isKeyboardVisible) return DesignTokens.spacing3;
    return _step == 1 ? DesignTokens.spacing2 : DesignTokens.spacing6;
  }

  double _contentSpacingForStep(bool isKeyboardVisible) {
    if (_step == 1) {
      return isKeyboardVisible ? DesignTokens.spacing3 : DesignTokens.spacing4;
    }
    return isKeyboardVisible ? DesignTokens.spacing4 : DesignTokens.spacing6;
  }

  double _titleFontSizeForStep(bool isKeyboardVisible) {
    if (_step == 1) {
      return isKeyboardVisible ? 28 : 30;
    }
    return isKeyboardVisible ? 30 : 34;
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        final domains = DomainService.getDomains();
        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth =
                (constraints.maxWidth - DesignTokens.spacing3) / 2;
            return SingleChildScrollView(
              child: Wrap(
                spacing: DesignTokens.spacing3,
                runSpacing: DesignTokens.spacing3,
                children: domains.map((LifeDomain domain) {
                  final selected = domain.id == _focusedDomainId;
                  return _DomainOptionCard(
                    domain: domain,
                    selected: selected,
                    width: cardWidth,
                    onTap: () {
                      setState(() {
                        _focusedDomainId = domain.id;
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      case 1:
        final characterCount = _goalController.text.trim().characters.length;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.spacing4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这一阶段，你最想推进什么？',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeBodyLarge,
                      fontWeight: DesignTokens.fontWeightSemiBold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  TextField(
                    controller: _goalController,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(80),
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      height: DesignTokens.lineHeightNormal,
                    ),
                    cursorColor: Colors.white,
                    maxLines: 4,
                    minLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: '例如：把副业跑通到第一个稳定成交闭环',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        height: DesignTokens.lineHeightNormal,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.03),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLarge,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLarge,
                        ),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusLarge,
                        ),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(
                        DesignTokens.spacing4,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '先写一句结果导向的话，后面再拆成目标下的项目和事项。',
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeBodySmall,
                            color: Colors.white.withOpacity(0.52),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacing3),
                      Text(
                        '$characterCount/80',
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeBodySmall,
                          color: Colors.white.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildBottomActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _primaryActionEnabled() ? _onPrimaryAction : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DesignTokens.backgroundDark,
              disabledBackgroundColor: Colors.white.withOpacity(0.2),
              disabledForegroundColor: Colors.white.withOpacity(0.72),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: DesignTokens.spacing4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  DesignTokens.radiusXLarge,
                ),
              ),
            ),
            child: Text(
              _step == 2 ? '进入 AI 拆解' : '继续',
              style: DesignTokens.textStyle(
                fontSize: DesignTokens.fontSizeBodyLarge,
                fontWeight: DesignTokens.fontWeightBold,
                color: _primaryActionEnabled()
                    ? DesignTokens.backgroundDark
                    : Colors.white.withOpacity(0.72),
              ),
            ),
          ),
        ),
        if (_step > 0) ...[
          const SizedBox(height: DesignTokens.spacing2),
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
      ],
    );
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

class _DomainOptionCard extends StatelessWidget {
  const _DomainOptionCard({
    required this.domain,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final LifeDomain domain;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _parseDomainColor(domain.color);
    final foregroundColor = selected
        ? DesignTokens.onBackgroundDark
        : Colors.white.withOpacity(0.92);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing4,
              vertical: DesignTokens.spacing3,
            ),
            constraints: const BoxConstraints(
              minHeight: 96,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              color: selected
                  ? accent.withOpacity(0.28)
                  : Colors.white.withOpacity(0.06),
              border: Border.all(
                color: selected
                    ? accent.withOpacity(0.9)
                    : Colors.white.withOpacity(0.12),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                        spreadRadius: -10,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? Colors.white.withOpacity(0.16)
                            : accent.withOpacity(0.18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        domain.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const Spacer(),
                    AnimatedContainer(
                      duration: DesignTokens.durationFast,
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? accent : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? accent
                              : Colors.white.withOpacity(0.28),
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacing3),
                Text(
                  domain.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeBodyLarge,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseDomainColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }
}

class OnboardingChecker {
  static const String key = 'has_seen_onboarding';

  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(key) ?? false);
  }
}
