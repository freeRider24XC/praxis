// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_review.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyReviewAdapter extends TypeAdapter<DailyReview> {
  @override
  final int typeId = 17;

  @override
  DailyReview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReview(
      id: fields[0] as String?,
      date: fields[1] as DateTime,
      whatDone: fields[2] as String?,
      blockers: fields[3] as String?,
      topPriorityTomorrow: fields[4] as String?,
      xpEarned: fields[5] as int?,
      isCompleted: fields[6] as bool?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyReview obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.whatDone)
      ..writeByte(3)
      ..write(obj.blockers)
      ..writeByte(4)
      ..write(obj.topPriorityTomorrow)
      ..writeByte(5)
      ..write(obj.xpEarned)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
