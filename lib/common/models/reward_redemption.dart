import 'package:hive/hive.dart';
import 'package:praxis/common/models/reward_template.dart';
import 'package:uuid/uuid.dart';

part 'reward_redemption.g.dart';

@HiveType(typeId: 22)
enum RewardRedemptionStatus {
  @HiveField(0)
  redeemed,
  @HiveField(1)
  completed,
  @HiveField(2)
  expired,
  @HiveField(3)
  cancelled,
}

extension RewardRedemptionStatusExtension on RewardRedemptionStatus {
  String get displayName {
    switch (this) {
      case RewardRedemptionStatus.redeemed:
        return '已兑换';
      case RewardRedemptionStatus.completed:
        return '已兑现';
      case RewardRedemptionStatus.expired:
        return '已过期';
      case RewardRedemptionStatus.cancelled:
        return '已取消';
    }
  }
}

@HiveType(typeId: 23)
class RewardRedemption extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String rewardTemplateId;

  @HiveField(2)
  late String titleSnapshot;

  @HiveField(3)
  late RewardTier tierSnapshot;

  @HiveField(4)
  late int priceSnapshot;

  @HiveField(5)
  late DateTime redeemedAt;

  @HiveField(6)
  late RewardRedemptionStatus status;

  @HiveField(7)
  String? rewardTodoId;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  RewardRedemption({
    String? id,
    required this.rewardTemplateId,
    required this.titleSnapshot,
    required this.tierSnapshot,
    required this.priceSnapshot,
    DateTime? redeemedAt,
    RewardRedemptionStatus? status,
    this.rewardTodoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        redeemedAt = redeemedAt ?? DateTime.now(),
        status = status ?? RewardRedemptionStatus.redeemed,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  RewardRedemption copyWith({
    String? id,
    String? rewardTemplateId,
    String? titleSnapshot,
    RewardTier? tierSnapshot,
    int? priceSnapshot,
    DateTime? redeemedAt,
    RewardRedemptionStatus? status,
    String? rewardTodoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewardRedemption(
      id: id ?? this.id,
      rewardTemplateId: rewardTemplateId ?? this.rewardTemplateId,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      tierSnapshot: tierSnapshot ?? this.tierSnapshot,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
      redeemedAt: redeemedAt ?? this.redeemedAt,
      status: status ?? this.status,
      rewardTodoId: rewardTodoId ?? this.rewardTodoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}