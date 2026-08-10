import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:praxis/common/i18n/app_strings.dart';
import 'package:praxis/common/style/design_tokens.dart';

class RewardShopPage extends StatefulWidget {
  const RewardShopPage({super.key});

  @override
  State<RewardShopPage> createState() => _RewardShopPageState();
}

class _RewardShopPageState extends State<RewardShopPage> {
  RewardTier? _tierFilter;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _refreshBalance();
  }

  void _refreshBalance() {
    _balance = DatabaseService.getUserProfile().praisePointsBalance;
  }

  List<RewardTemplate> _filteredTemplates() {
    final list = RewardService.getEnabledTemplates();
    if (_tierFilter == null) return list;
    return list.where((t) => t.tier == _tierFilter).toList();
  }

  Future<void> _confirmExchange(RewardTemplate template) async {
    final balance = DatabaseService.getUserProfile().praisePointsBalance;
    if (balance < template.priceInPraisePoints) {
      Get.snackbar(
        AppStrings.rewardInsufficientPoints.tr,
        '${AppStrings.rewardShopBalance.trNamed({'points': '$balance'})}，'
            '需要 ${template.priceInPraisePoints}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(AppStrings.rewardExchangeConfirmTitle.tr),
        content: Text(
          AppStrings.rewardExchangeConfirmBody.trNamed({
            'price': template.priceInPraisePoints.toString(),
            'title': template.title,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(AppStrings.cancel.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.statusCompleted,
            ),
            child: Text(AppStrings.confirm.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await RewardService.exchange(template);
      if (!mounted) return;
      setState(_refreshBalance);
      Get.snackbar(
        template.title,
        AppStrings.rewardExchangeSuccess.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on InsufficientPraisePointsException {
      Get.snackbar(
        AppStrings.rewardInsufficientPoints.tr,
        '',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templates = _filteredTemplates();

    return Scaffold(
      backgroundColor:
          isDark ? DesignTokens.backgroundDark : DesignTokens.backgroundLight,
      appBar: AppBar(
        title: Text(AppStrings.rewardShopTitle.tr),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing4,
              vertical: DesignTokens.spacing2,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacing3,
                  vertical: DesignTokens.spacing1,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.statusCompleted.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
                ),
                child: Text(
                  AppStrings.rewardShopBalance.trNamed({'points': '$_balance'}),
                  style: DesignTokens.textStyle(
                    fontSize: DesignTokens.fontSizeLabelSmall,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: DesignTokens.statusCompleted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTodoBanner(isDark),
          _buildTierFilter(isDark),
          Expanded(
            child: templates.isEmpty
                ? _buildEmptyHint(isDark)
                : ListView(
                    padding: const EdgeInsets.all(DesignTokens.spacing6),
                    children: _buildSections(templates, isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoBanner(bool isDark) {
    final pendingCount = DatabaseService.rewardTodoBox.values
        .where((t) =>
            t.status == RewardTodoStatus.pending ||
            t.status == RewardTodoStatus.expired)
        .length;
    if (pendingCount == 0) return const SizedBox.shrink();
    return InkWell(
      onTap: () => Get.toNamed('/reward/todo'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          DesignTokens.spacing6,
          DesignTokens.spacing3,
          DesignTokens.spacing6,
          0,
        ),
        padding: const EdgeInsets.all(DesignTokens.spacing4),
        decoration: BoxDecoration(
          color: DesignTokens.statusActive.withOpacity(0.12),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.redeem,
              color: DesignTokens.statusActive,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.spacing3),
            Expanded(
              child: Text(
                '${AppStrings.rewardShopMyTodosCta.tr} · $pendingCount ${AppStrings.rewardTodoGroupPending.tr}',
                style: DesignTokens.textStyle(
                  fontWeight: DesignTokens.fontWeightBold,
                  color: DesignTokens.statusActive,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: DesignTokens.statusActive,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierFilter(bool isDark) {
    final filters = <(RewardTier?, String)>[
      (null, AppStrings.rewardTierFilterAll.tr),
      (RewardTier.small, AppStrings.rewardTierSmall.tr),
      (RewardTier.medium, AppStrings.rewardTierMedium.tr),
      (RewardTier.large, AppStrings.rewardTierLarge.tr),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing6,
        vertical: DesignTokens.spacing3,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((entry) {
            final selected = _tierFilter == entry.$1;
            return Padding(
              padding: const EdgeInsets.only(right: DesignTokens.spacing2),
              child: ChoiceChip(
                label: Text(entry.$2),
                selected: selected,
                onSelected: (_) => setState(() => _tierFilter = entry.$1),
                selectedColor: DesignTokens.primaryColor.withOpacity(0.18),
                labelStyle: DesignTokens.textStyle(
                  fontWeight: selected
                      ? DesignTokens.fontWeightBold
                      : DesignTokens.fontWeightMedium,
                  color: selected
                      ? DesignTokens.primaryColor
                      : (isDark
                          ? DesignTokens.onSurfaceDark
                          : DesignTokens.onSurfaceLight),
                ),
                side: BorderSide(
                  color: selected
                      ? DesignTokens.primaryColor
                      : (isDark
                          ? DesignTokens.borderDark
                          : DesignTokens.borderLight),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildSections(List<RewardTemplate> templates, bool isDark) {
    if (_tierFilter != null) {
      return templates.map((t) => _buildRewardCard(t, isDark)).toList();
    }
    final byTier = <RewardTier, List<RewardTemplate>>{};
    for (final t in templates) {
      byTier.putIfAbsent(t.tier, () => []).add(t);
    }
    final order = [RewardTier.small, RewardTier.medium, RewardTier.large];
    final widgets = <Widget>[];
    for (final tier in order) {
      final group = byTier[tier];
      if (group == null || group.isEmpty) continue;
      widgets.add(_buildSectionHeader(tier, isDark));
      for (final t in group) {
        widgets.add(_buildRewardCard(t, isDark));
      }
    }
    return widgets;
  }

  Widget _buildSectionHeader(RewardTier tier, bool isDark) {
    final label = switch (tier) {
      RewardTier.small => AppStrings.rewardTierSmall.tr,
      RewardTier.medium => AppStrings.rewardTierMedium.tr,
      RewardTier.large => AppStrings.rewardTierLarge.tr,
    };
    final color = switch (tier) {
      RewardTier.small => DesignTokens.statusActive,
      RewardTier.medium => DesignTokens.warningColor,
      RewardTier.large => DesignTokens.secondaryPurple,
    };
    return Padding(
      padding: const EdgeInsets.only(
        bottom: DesignTokens.spacing3,
        top: DesignTokens.spacing2,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: DesignTokens.spacing2),
          Text(
            label,
            style: DesignTokens.textStyle(
              fontSize: DesignTokens.fontSizeTitleLarge,
              fontWeight: DesignTokens.fontWeightBold,
              color: isDark
                  ? DesignTokens.onSurfaceDark
                  : DesignTokens.onSurfaceLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(RewardTemplate template, bool isDark) {
    final canAfford = _balance >= template.priceInPraisePoints;
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacing3),
      padding: const EdgeInsets.all(DesignTokens.spacing4),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: isDark ? DesignTokens.borderDark : DesignTokens.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        template.title,
                        style: DesignTokens.textStyle(
                          fontSize: DesignTokens.fontSizeBodyLarge,
                          fontWeight: DesignTokens.fontWeightBold,
                          color: isDark
                              ? DesignTokens.onSurfaceDark
                              : DesignTokens.onSurfaceLight,
                        ),
                      ),
                    ),
                    if (template.isSystemPreset) ...[
                      const SizedBox(width: DesignTokens.spacing2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacing2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              DesignTokens.secondaryPurple.withOpacity(0.12),
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusSmall),
                        ),
                        child: Text(
                          AppStrings.rewardShopPresetBadge.tr,
                          style: DesignTokens.textStyle(
                            fontSize: DesignTokens.fontSizeLabelSmall,
                            fontWeight: DesignTokens.fontWeightBold,
                            color: DesignTokens.secondaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (template.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: DesignTokens.spacing1),
                  Text(
                    template.description!,
                    style: DesignTokens.textStyle(
                      fontSize: DesignTokens.fontSizeLabelSmall,
                      color: isDark
                          ? DesignTokens.textSecondaryDark
                          : DesignTokens.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: DesignTokens.spacing3),
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: DesignTokens.warningColor),
                    const SizedBox(width: 2),
                    Text(
                      '${template.priceInPraisePoints}',
                      style: DesignTokens.textStyle(
                        fontSize: DesignTokens.fontSizeBodyMedium,
                        fontWeight: DesignTokens.fontWeightBold,
                        color: canAfford
                            ? DesignTokens.primaryColor
                            : DesignTokens.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spacing3),
          ElevatedButton(
            onPressed: canAfford ? () => _confirmExchange(template) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford
                  ? DesignTokens.statusCompleted
                  : DesignTokens.surfaceLightSecondary,
              foregroundColor: canAfford
                  ? Colors.white
                  : DesignTokens.textSecondaryLight,
              disabledBackgroundColor: isDark
                  ? DesignTokens.surfaceDarkSecondary
                  : DesignTokens.surfaceLightSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing4,
                vertical: DesignTokens.spacing2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            child: Text(
              AppStrings.rewardExchangeAction.tr,
              style: DesignTokens.textStyle(
                fontWeight: DesignTokens.fontWeightBold,
                color: canAfford
                    ? Colors.white
                    : DesignTokens.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing6),
        child: Text(
          AppStrings.rewardShopEmptyHint.tr,
          style: DesignTokens.textStyle(
            color: isDark
                ? DesignTokens.textSecondaryDark
                : DesignTokens.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
