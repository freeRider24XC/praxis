import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:praxis/common/models/index.dart';
import 'package:praxis/common/services/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _initDb({bool seed = false}) async {
  SharedPreferences.setMockInitialValues({});
  final tempDir = path.join(
    Directory.systemTemp.path,
    'praxis_reward_test_${DateTime.now().microsecondsSinceEpoch}',
  );
  await DatabaseService.init(hivePath: tempDir);
  await DatabaseService.clearAllData();
  if (seed) {
    await RewardService.seedPresetTemplatesIfEmpty();
  }
}

void main() {
  test('seedPresetTemplatesIfEmpty seeds 15 templates across 3 tiers', () async {
    await _initDb();
    await RewardService.seedPresetTemplatesIfEmpty();
    final templates = DatabaseService.rewardTemplateBox.values.toList();
    expect(templates.length, 15);
    expect(templates.where((t) => t.tier == RewardTier.small).length, 5);
    expect(templates.where((t) => t.tier == RewardTier.medium).length, 5);
    expect(templates.where((t) => t.tier == RewardTier.large).length, 5);
    expect(templates.every((t) => t.isSystemPreset), isTrue);
  });

  test('seedPresetTemplatesIfEmpty is idempotent on repeat calls', () async {
    await _initDb();
    await RewardService.seedPresetTemplatesIfEmpty();
    final before = DatabaseService.rewardTemplateBox.values.length;
    await RewardService.seedPresetTemplatesIfEmpty();
    await RewardService.seedPresetTemplatesIfEmpty();
    final after = DatabaseService.rewardTemplateBox.values.length;
    expect(after, before);
  });

  test('getEnabledTemplates returns enabled templates sorted by sortOrder',
      () async {
    await _initDb(seed: true);
    final enabled = RewardService.getEnabledTemplates();
    expect(enabled.length, 15);
    for (var i = 1; i < enabled.length; i++) {
      expect(
        enabled[i - 1].sortOrder <= enabled[i].sortOrder,
        isTrue,
        reason: 'sortOrder should be non-decreasing',
      );
    }
  });

  test('exchange deducts points, creates redemption and reward todo', () async {
    await _initDb(seed: true);
    const balance = RewardService.mediumPrice + 10;
    await ProfileService.incrementPraisePoints(balance);

    final template = DatabaseService.rewardTemplateBox.values.firstWhere(
      (t) => t.tier == RewardTier.medium,
    );

    final redemption = await RewardService.exchange(template);

    final profile = DatabaseService.getUserProfile();
    expect(
      profile.praisePointsBalance,
      balance - template.priceInPraisePoints,
    );

    final redemptions = DatabaseService.rewardRedemptionBox.values;
    expect(redemptions.length, 1);
    expect(redemptions.first.id, redemption.id);
    expect(redemptions.first.titleSnapshot, template.title);
    expect(redemptions.first.tierSnapshot, template.tier);
    expect(redemptions.first.priceSnapshot, template.priceInPraisePoints);
    expect(redemptions.first.status, RewardRedemptionStatus.redeemed);

    final rewardTodos = DatabaseService.rewardTodoBox.values;
    expect(rewardTodos.length, 1);
    expect(rewardTodos.first.title, '兑现：${template.title}');
    expect(rewardTodos.first.status, RewardTodoStatus.pending);
    expect(rewardTodos.first.redemptionId, redemption.id);
    expect(redemptions.first.rewardTodoId, rewardTodos.first.id);
    expect(rewardTodos.first.dueDate, isNotNull);
  });

  test('exchange throws InsufficientPraisePointsException when balance low',
      () async {
    await _initDb(seed: true);
    final template = DatabaseService.rewardTemplateBox.values.firstWhere(
      (t) => t.tier == RewardTier.large,
    );
    // Don't seed any balance; defaults to 0
    expect(
      () => RewardService.exchange(template),
      throwsA(isA<InsufficientPraisePointsException>()),
    );
    expect(DatabaseService.rewardRedemptionBox.values, isEmpty);
    expect(DatabaseService.rewardTodoBox.values, isEmpty);
  });

  test('exchange does not deduct when balance insufficient', () async {
    await _initDb(seed: true);
    await ProfileService.incrementPraisePoints(3); // far below any preset
    final balanceBefore = DatabaseService.getUserProfile().praisePointsBalance;
    final template = DatabaseService.rewardTemplateBox.values.firstWhere(
      (t) => t.tier == RewardTier.small,
    );

    expect(
      () => RewardService.exchange(template),
      throwsA(isA<InsufficientPraisePointsException>()),
    );

    final balanceAfter = DatabaseService.getUserProfile().praisePointsBalance;
    expect(balanceAfter, balanceBefore);
  });
}
