import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 15)
class UserProfile extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? focusedDomainId;

  @HiveField(2)
  late int totalXp;

  @HiveField(3)
  late int level;

  @HiveField(4)
  late int streakDays;

  @HiveField(5)
  late int weeklyCapacityHours;

  @HiveField(6)
  DateTime? lastActiveDate;

  @HiveField(7)
  late DateTime createdAt;

  @HiveField(8)
  late DateTime updatedAt;

  @HiveField(9)
  int praisePointsBalance = 0;

  UserProfile({
    String? id,
    this.focusedDomainId,
    int? totalXp,
    int? level,
    int? streakDays,
    int? weeklyCapacityHours,
    this.lastActiveDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? praisePointsBalance,
  })  : id = id ?? const Uuid().v4(),
        totalXp = totalXp ?? 0,
        level = level ?? 1,
        streakDays = streakDays ?? 0,
        weeklyCapacityHours = weeklyCapacityHours ?? 5,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        praisePointsBalance = praisePointsBalance ?? 0;

  UserProfile copyWith({
    String? id,
    String? focusedDomainId,
    int? totalXp,
    int? level,
    int? streakDays,
    int? weeklyCapacityHours,
    DateTime? lastActiveDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? praisePointsBalance,
  }) {
    return UserProfile(
      id: id ?? this.id,
      focusedDomainId: focusedDomainId ?? this.focusedDomainId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      weeklyCapacityHours: weeklyCapacityHours ?? this.weeklyCapacityHours,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      praisePointsBalance: praisePointsBalance ?? this.praisePointsBalance,
    );
  }
}
