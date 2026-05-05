import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/daily_review.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class DailyReviewPage extends StatefulWidget {
  const DailyReviewPage({super.key});

  @override
  State<DailyReviewPage> createState() => _DailyReviewPageState();
}

class _DailyReviewPageState extends State<DailyReviewPage> {
  final _doneController = TextEditingController();
  final _blockersController = TextEditingController();
  final _tomorrowController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final today = DatabaseService.getDailyReviewByDate(DateTime.now());
    if (today != null) {
      _doneController.text = today.whatDone ?? '';
      _blockersController.text = today.blockers ?? '';
      _tomorrowController.text = today.topPriorityTomorrow ?? '';
    }
  }

  @override
  void dispose() {
    _doneController.dispose();
    _blockersController.dispose();
    _tomorrowController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSaving = true;
    });

    final existing = DatabaseService.getDailyReviewByDate(DateTime.now());

    final review = DailyReview(
      date: DateTime.now(),
      whatDone: _doneController.text.trim(),
      blockers: _blockersController.text.trim(),
      topPriorityTomorrow: _tomorrowController.text.trim(),
      xpEarned: XpService.dailyReviewXp,
      isCompleted: true,
    );

    await DatabaseService.upsertDailyReview(review);
    if (existing == null || !existing.isCompleted) {
      await XpService.awardDailyReview(review);
    }
    final feedback = await AiUseCaseService().reviewDay(review: review);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    await Get.dialog(
      AlertDialog(
        title: const Text('今日复盘已完成'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feedback.summary),
            const SizedBox(height: DesignTokens.spacing3),
            Text(
              feedback.focus,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('每日复盘')),
      backgroundColor: isDark
          ? DesignTokens.backgroundDark
          : DesignTokens.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        children: [
          _buildInputCard(
            isDark: isDark,
            title: '今天完成了什么？',
            controller: _doneController,
            hint: '写下今天最有推进感的事情',
          ),
          const SizedBox(height: DesignTokens.spacing4),
          _buildInputCard(
            isDark: isDark,
            title: '今天卡住了什么？',
            controller: _blockersController,
            hint: '记录一下真正拖住你的地方',
          ),
          const SizedBox(height: DesignTokens.spacing4),
          _buildInputCard(
            isDark: isDark,
            title: '明天最重要的一件事是什么？',
            controller: _tomorrowController,
            hint: '只写一件最值得先做的事',
          ),
          const SizedBox(height: DesignTokens.spacing6),
          ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            child: Text(_isSaving ? '提交中...' : '提交复盘并领取 +20 XP'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required bool isDark,
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacing5),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeBodyLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
          const SizedBox(height: DesignTokens.spacing3),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
