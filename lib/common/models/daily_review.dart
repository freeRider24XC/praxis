import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'daily_review.g.dart';

@HiveType(typeId: 17)
class DailyReview extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  String? whatDone;

  @HiveField(3)
  String? blockers;

  @HiveField(4)
  String? topPriorityTomorrow;

  @HiveField(5)
  late int xpEarned;

  @HiveField(6)
  late bool isCompleted;

  @HiveField(7)
  late DateTime createdAt;

  DailyReview({
    String? id,
    required this.date,
    this.whatDone,
    this.blockers,
    this.topPriorityTomorrow,
    int? xpEarned,
    bool? isCompleted,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        xpEarned = xpEarned ?? 0,
        isCompleted = isCompleted ?? false,
        createdAt = createdAt ?? DateTime.now();

  DailyReview copyWith({
    String? id,
    DateTime? date,
    String? whatDone,
    String? blockers,
    String? topPriorityTomorrow,
    int? xpEarned,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return DailyReview(
      id: id ?? this.id,
      date: date ?? this.date,
      whatDone: whatDone ?? this.whatDone,
      blockers: blockers ?? this.blockers,
      topPriorityTomorrow: topPriorityTomorrow ?? this.topPriorityTomorrow,
      xpEarned: xpEarned ?? this.xpEarned,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
