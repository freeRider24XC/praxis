// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_redemption.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardRedemptionAdapter extends TypeAdapter<RewardRedemption> {
  @override
  final int typeId = 23;

  @override
  RewardRedemption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardRedemption(
      id: fields[0] as String?,
      rewardTemplateId: fields[1] as String,
      titleSnapshot: fields[2] as String,
      tierSnapshot: fields[3] as RewardTier,
      priceSnapshot: fields[4] as int,
      redeemedAt: fields[5] as DateTime?,
      status: fields[6] as RewardRedemptionStatus?,
      rewardTodoId: fields[7] as String?,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardRedemption obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rewardTemplateId)
      ..writeByte(2)
      ..write(obj.titleSnapshot)
      ..writeByte(3)
      ..write(obj.tierSnapshot)
      ..writeByte(4)
      ..write(obj.priceSnapshot)
      ..writeByte(5)
      ..write(obj.redeemedAt)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.rewardTodoId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardRedemptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardRedemptionStatusAdapter
    extends TypeAdapter<RewardRedemptionStatus> {
  @override
  final int typeId = 22;

  @override
  RewardRedemptionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardRedemptionStatus.redeemed;
      case 1:
        return RewardRedemptionStatus.completed;
      case 2:
        return RewardRedemptionStatus.expired;
      case 3:
        return RewardRedemptionStatus.cancelled;
      default:
        return RewardRedemptionStatus.redeemed;
    }
  }

  @override
  void write(BinaryWriter writer, RewardRedemptionStatus obj) {
    switch (obj) {
      case RewardRedemptionStatus.redeemed:
        writer.writeByte(0);
        break;
      case RewardRedemptionStatus.completed:
        writer.writeByte(1);
        break;
      case RewardRedemptionStatus.expired:
        writer.writeByte(2);
        break;
      case RewardRedemptionStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardRedemptionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
