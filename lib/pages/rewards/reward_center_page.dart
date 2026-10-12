import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/style/design_tokens.dart';

class RewardCenterPage extends StatefulWidget {
  const RewardCenterPage({super.key});

  @override
  State<RewardCenterPage> createState() => _RewardCenterPageState();
}

class _RewardCenterPageState extends State<RewardCenterPage> {
  late List<RewardTemplate> _templates;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _templates = DatabaseService.getRewardTemplates();
      _balance = DatabaseService.getPraisePointBalance();
    });
  }

  Future<void> _redeem(RewardTemplate template) async {
    try {
      await RewardService.exchange(template);
      _load();
      if (!mounted) return;
      Get.snackbar('兑换成功', '已生成奖励待办，记得真正去兑现。');
    } catch (error) {
      if (!mounted) return;
      Get.snackbar('兑换失败', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentProject = DatabaseService.getAllProjects().firstWhereOrNull(
      (project) =>
          project.status == ProjectStatus.active ||
          project.status == ProjectStatus.planning,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('奖励中心')),
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing5),
            decoration: BoxDecoration(
              color: isDark ? DesignTokens.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前犒赏点',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing2),
                Text(
                  '$_balance',
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeDisplaySmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: isDark
                        ? DesignTokens.onSurfaceDark
                        : DesignTokens.onSurfaceLight,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacing2),
                Text(
                  currentProject == null
                      ? '先完成关键推进动作，再把犒赏点换成真实奖励。'
                      : '这些犒赏点来自你对“${currentProject.name}”的真实推进，兑换后记得真的去兑现。',
                  style: DesignTokens.textStyle(
                    color: isDark
                        ? DesignTokens.textSecondaryDark
                        : DesignTokens.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spacing5),
          ..._templates.map((template) {
            final canRedeem = _balance >= template.priceInPraisePoints;
            return Container(
              margin: const EdgeInsets.only(bottom: DesignTokens.spacing4),
              padding: const EdgeInsets.all(DesignTokens.spacing5),
              decoration: BoxDecoration(
                color: isDark ? DesignTokens.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeTitleMedium,
                      fontWeight: DesignTokens.fontWeightBold,
                      color: isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight,
                    ),
                  ),
                  if ((template.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: DesignTokens.spacing2),
                    Text(template.description!),
                  ],
                  const SizedBox(height: DesignTokens.spacing2),
                  Text(
                    '这是项目推进后的现实奖励，不是停留在界面里的勾选。',
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${template.priceInPraisePoints} 点'),
                      ElevatedButton(
                        onPressed: canRedeem ? () => _redeem(template) : null,
                        child: const Text('兑换'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
