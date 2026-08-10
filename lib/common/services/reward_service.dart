import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/database_service.dart';
import 'package:praxis/common/services/profile_service.dart';

/// 异常：余额不足，无法兑换
class InsufficientPraisePointsException implements Exception {
  final int balance;
  final int required;
  InsufficientPraisePointsException(this.balance, this.required);

  @override
  String toString() => '余额不足：当前 $balance 犒赏点，需要 $required';
}

class RewardService {
  static const int smallPrice = 5;
  static const int mediumPrice = 15;
  static const int largePrice = 50;
  static const Duration redemptionValidity = Duration(days: 7);

  /// 首次启动时种入蓝图 §11.1 的 15 个预设奖励模板。已存在则跳过，幂等。
  static Future<void> seedPresetTemplatesIfEmpty() async {
    final box = DatabaseService.rewardTemplateBox;
    final hasPreset = box.values.any((t) => t.isSystemPreset);
    if (hasPreset) return;

    final now = DateTime.now();
    final presets = <RewardTemplate>[
      // 小奖励
      RewardTemplate(title: '摸鱼卡', tier: RewardTier.small, priceInPraisePoints: smallPrice, isSystemPreset: true, sortOrder: 10, createdAt: now, updatedAt: now),
      RewardTemplate(title: '奶茶卡', tier: RewardTier.small, priceInPraisePoints: smallPrice, isSystemPreset: true, sortOrder: 11, createdAt: now, updatedAt: now),
      RewardTemplate(title: '游戏时间卡', tier: RewardTier.small, priceInPraisePoints: smallPrice, isSystemPreset: true, sortOrder: 12, createdAt: now, updatedAt: now),
      RewardTemplate(title: '泡澡卡', tier: RewardTier.small, priceInPraisePoints: smallPrice, isSystemPreset: true, sortOrder: 13, createdAt: now, updatedAt: now),
      RewardTemplate(title: '散步卡', tier: RewardTier.small, priceInPraisePoints: smallPrice, isSystemPreset: true, sortOrder: 14, createdAt: now, updatedAt: now),
      // 中奖励
      RewardTemplate(title: '购物卡', tier: RewardTier.medium, priceInPraisePoints: mediumPrice, isSystemPreset: true, sortOrder: 20, createdAt: now, updatedAt: now),
      RewardTemplate(title: '电影夜', tier: RewardTier.medium, priceInPraisePoints: mediumPrice, isSystemPreset: true, sortOrder: 21, createdAt: now, updatedAt: now),
      RewardTemplate(title: '一顿想吃的', tier: RewardTier.medium, priceInPraisePoints: mediumPrice, isSystemPreset: true, sortOrder: 22, createdAt: now, updatedAt: now),
      RewardTemplate(title: '买一本书', tier: RewardTier.medium, priceInPraisePoints: mediumPrice, isSystemPreset: true, sortOrder: 23, createdAt: now, updatedAt: now),
      RewardTemplate(title: '周末半天放空', tier: RewardTier.medium, priceInPraisePoints: mediumPrice, isSystemPreset: true, sortOrder: 24, createdAt: now, updatedAt: now),
      // 大奖励
      RewardTemplate(title: '按摩卡', tier: RewardTier.large, priceInPraisePoints: largePrice, isSystemPreset: true, sortOrder: 30, createdAt: now, updatedAt: now),
      RewardTemplate(title: 'SPA 卡', tier: RewardTier.large, priceInPraisePoints: largePrice, isSystemPreset: true, sortOrder: 31, createdAt: now, updatedAt: now),
      RewardTemplate(title: '短途旅行卡', tier: RewardTier.large, priceInPraisePoints: largePrice, isSystemPreset: true, sortOrder: 32, createdAt: now, updatedAt: now),
      RewardTemplate(title: '装备升级卡', tier: RewardTier.large, priceInPraisePoints: largePrice, isSystemPreset: true, sortOrder: 33, createdAt: now, updatedAt: now),
      RewardTemplate(title: '预算型购物奖励', tier: RewardTier.large, priceInPraisePoints: largePrice, isSystemPreset: true, sortOrder: 34, createdAt: now, updatedAt: now),
    ];

    for (final tpl in presets) {
      await box.add(tpl);
    }
  }

  static List<RewardTemplate> getEnabledTemplates() {
    final list = DatabaseService.rewardTemplateBox.values
        .where((t) => t.isEnabled)
        .toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// 兑换流程：余额校验 → 扣点 → 创建 redemption + rewardTodo，返回 Redemption。
  /// 若余额不足抛 InsufficientPraisePointsException，不改任何状态。
  static Future<RewardRedemption> exchange(RewardTemplate template) async {
    final balance = DatabaseService.getUserProfile().praisePointsBalance;
    if (balance < template.priceInPraisePoints) {
      throw InsufficientPraisePointsException(
        balance,
        template.priceInPraisePoints,
      );
    }

    await ProfileService.incrementPraisePoints(-template.priceInPraisePoints);

    final now = DateTime.now();
    final dueDate = now.add(redemptionValidity);

    final todo = RewardTodo(
      redemptionId: '', // 占位，下面 redemptionBox.add 之后再回填
      title: '兑现：${template.title}',
      status: RewardTodoStatus.pending,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
    await DatabaseService.rewardTodoBox.add(todo);

    final redemption = RewardRedemption(
      rewardTemplateId: template.id,
      titleSnapshot: template.title,
      tierSnapshot: template.tier,
      priceSnapshot: template.priceInPraisePoints,
      redeemedAt: now,
      status: RewardRedemptionStatus.redeemed,
      rewardTodoId: todo.id,
      createdAt: now,
      updatedAt: now,
    );
    await DatabaseService.rewardRedemptionBox.add(redemption);

    todo.redemptionId = redemption.id;
    todo.updatedAt = now;
    await todo.save();

    return redemption;
  }
}
