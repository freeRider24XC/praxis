// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardTemplateAdapter extends TypeAdapter<RewardTemplate> {
  @override
  final int typeId = 21;

  @override
  RewardTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardTemplate(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      tier: fields[3] as RewardTier,
      priceInPraisePoints: fields[4] as int,
      isSystemPreset: fields[5] as bool,
      isEnabled: fields[6] as bool,
      sortOrder: fields[7] as int,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardTemplate obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.tier)
      ..writeByte(4)
      ..write(obj.priceInPraisePoints)
      ..writeByte(5)
      ..write(obj.isSystemPreset)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.sortOrder)
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
      other is RewardTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTierAdapter extends TypeAdapter<RewardTier> {
  @override
  final int typeId = 20;

  @override
  RewardTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardTier.small;
      case 1:
        return RewardTier.medium;
      case 2:
        return RewardTier.large;
      default:
        return RewardTier.small;
    }
  }

  @override
  void write(BinaryWriter writer, RewardTier obj) {
    switch (obj) {
      case RewardTier.small:
        writer.writeByte(0);
        break;
      case RewardTier.medium:
        writer.writeByte(1);
        break;
      case RewardTier.large:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
