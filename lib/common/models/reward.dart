import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'reward.g.dart';

@HiveType(typeId: 21)
class PraisePointLedger extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late int delta;

  @HiveField(2)
  late PraisePointSource source;

  @HiveField(3)
  late String sourceId;

  @HiveField(4)
  late String description;

  @HiveField(5)
  late DateTime createdAt;

  PraisePointLedger({
    String? id,
    required this.delta,
    required this.source,
    required this.sourceId,
    required this.description,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 22)
enum PraisePointSource {
  @HiveField(0)
  todoCompleted,
  @HiveField(1)
  projectCompleted,
  @HiveField(2)
  goalCompleted,
  @HiveField(3)
  dailyReview,
  @HiveField(4)
  rewardRedemption,
}

@HiveType(typeId: 23)
enum RewardTier {
  @HiveField(0)
  small,
  @HiveField(1)
  medium,
  @HiveField(2)
  large,
}

@HiveType(typeId: 24)
class RewardTemplate extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late int priceInPraisePoints;

  @HiveField(4)
  late RewardTier tier;

  @HiveField(5)
  late bool isSystemTemplate;

  @HiveField(6)
  late DateTime createdAt;

  RewardTemplate({
    String? id,
    required this.title,
    this.description,
    required this.priceInPraisePoints,
    RewardTier? tier,
    bool? isSystemTemplate,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        tier = tier ?? RewardTier.small,
        isSystemTemplate = isSystemTemplate ?? true,
        createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 25)
enum RewardRedemptionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  fulfilled,
  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 26)
class RewardRedemption extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String rewardTemplateId;

  @HiveField(2)
  late int priceInPraisePoints;

  @HiveField(3)
  String? rewardTodoId;

  @HiveField(4)
  late RewardRedemptionStatus status;

  @HiveField(5)
  late DateTime createdAt;

  RewardRedemption({
    String? id,
    required this.rewardTemplateId,
    required this.priceInPraisePoints,
    this.rewardTodoId,
    RewardRedemptionStatus? status,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? RewardRedemptionStatus.pending,
        createdAt = createdAt ?? DateTime.now();
}

@HiveType(typeId: 27)
enum RewardTodoStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
}

@HiveType(typeId: 28)
class RewardTodo extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String rewardTemplateId;

  @HiveField(2)
  late String redemptionId;

  @HiveField(3)
  late String title;

  @HiveField(4)
  String? description;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  late RewardTodoStatus status;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  DateTime? completedAt;

  RewardTodo({
    String? id,
    required this.rewardTemplateId,
    required this.redemptionId,
    required this.title,
    this.description,
    this.dueDate,
    RewardTodoStatus? status,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? RewardTodoStatus.pending,
        createdAt = createdAt ?? DateTime.now();
}
