// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 15;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String?,
      focusedDomainId: fields[1] as String?,
      totalXp: fields[2] as int?,
      level: fields[3] as int?,
      streakDays: fields[4] as int?,
      weeklyCapacityHours: fields[5] as int?,
      lastActiveDate: fields[6] as DateTime?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
      praisePointsBalance: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.focusedDomainId)
      ..writeByte(2)
      ..write(obj.totalXp)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.streakDays)
      ..writeByte(5)
      ..write(obj.weeklyCapacityHours)
      ..writeByte(6)
      ..write(obj.lastActiveDate)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.praisePointsBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
