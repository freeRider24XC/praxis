import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reward_template.g.dart';

@HiveType(typeId: 20)
enum RewardTier {
  @HiveField(0)
  small,
  @HiveField(1)
  medium,
  @HiveField(2)
  large,
}

extension RewardTierExtension on RewardTier {
  String get displayName {
    switch (this) {
      case RewardTier.small:
        return '小奖励';
      case RewardTier.medium:
        return '中奖励';
      case RewardTier.large:
        return '大奖励';
    }
  }
}

@HiveType(typeId: 21)
class RewardTemplate extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late RewardTier tier;

  @HiveField(4)
  late int priceInPraisePoints;

  @HiveField(5)
  late bool isSystemPreset;

  @HiveField(6)
  late bool isEnabled;

  @HiveField(7)
  late int sortOrder;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  late DateTime updatedAt;

  RewardTemplate({
    String? id,
    required this.title,
    this.description,
    required this.tier,
    required this.priceInPraisePoints,
    this.isSystemPreset = false,
    this.isEnabled = true,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  RewardTemplate copyWith({
    String? id,
    String? title,
    String? description,
    RewardTier? tier,
    int? priceInPraisePoints,
    bool? isSystemPreset,
    bool? isEnabled,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RewardTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tier: tier ?? this.tier,
      priceInPraisePoints: priceInPraisePoints ?? this.priceInPraisePoints,
      isSystemPreset: isSystemPreset ?? this.isSystemPreset,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}