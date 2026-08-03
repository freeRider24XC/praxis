// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PraisePointLedgerAdapter extends TypeAdapter<PraisePointLedger> {
  @override
  final int typeId = 21;

  @override
  PraisePointLedger read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PraisePointLedger(
      id: fields[0] as String?,
      delta: fields[1] as int,
      source: fields[2] as PraisePointSource,
      sourceId: fields[3] as String,
      description: fields[4] as String,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PraisePointLedger obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.delta)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.sourceId)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PraisePointLedgerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTemplateAdapter extends TypeAdapter<RewardTemplate> {
  @override
  final int typeId = 24;

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
      priceInPraisePoints: fields[3] as int,
      tier: fields[4] as RewardTier?,
      isSystemTemplate: fields[5] as bool?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardTemplate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priceInPraisePoints)
      ..writeByte(4)
      ..write(obj.tier)
      ..writeByte(5)
      ..write(obj.isSystemTemplate)
      ..writeByte(6)
      ..write(obj.createdAt);
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

class RewardRedemptionAdapter extends TypeAdapter<RewardRedemption> {
  @override
  final int typeId = 26;

  @override
  RewardRedemption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardRedemption(
      id: fields[0] as String?,
      rewardTemplateId: fields[1] as String,
      priceInPraisePoints: fields[2] as int,
      rewardTodoId: fields[3] as String?,
      status: fields[4] as RewardRedemptionStatus?,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardRedemption obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rewardTemplateId)
      ..writeByte(2)
      ..write(obj.priceInPraisePoints)
      ..writeByte(3)
      ..write(obj.rewardTodoId)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt);
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

class RewardTodoAdapter extends TypeAdapter<RewardTodo> {
  @override
  final int typeId = 28;

  @override
  RewardTodo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardTodo(
      id: fields[0] as String?,
      rewardTemplateId: fields[1] as String,
      redemptionId: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String?,
      dueDate: fields[5] as DateTime?,
      status: fields[6] as RewardTodoStatus?,
      createdAt: fields[7] as DateTime?,
      completedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardTodo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rewardTemplateId)
      ..writeByte(2)
      ..write(obj.redemptionId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PraisePointSourceAdapter extends TypeAdapter<PraisePointSource> {
  @override
  final int typeId = 22;

  @override
  PraisePointSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PraisePointSource.todoCompleted;
      case 1:
        return PraisePointSource.projectCompleted;
      case 2:
        return PraisePointSource.goalCompleted;
      case 3:
        return PraisePointSource.dailyReview;
      case 4:
        return PraisePointSource.rewardRedemption;
      default:
        return PraisePointSource.todoCompleted;
    }
  }

  @override
  void write(BinaryWriter writer, PraisePointSource obj) {
    switch (obj) {
      case PraisePointSource.todoCompleted:
        writer.writeByte(0);
        break;
      case PraisePointSource.projectCompleted:
        writer.writeByte(1);
        break;
      case PraisePointSource.goalCompleted:
        writer.writeByte(2);
        break;
      case PraisePointSource.dailyReview:
        writer.writeByte(3);
        break;
      case PraisePointSource.rewardRedemption:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PraisePointSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTierAdapter extends TypeAdapter<RewardTier> {
  @override
  final int typeId = 23;

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

class RewardRedemptionStatusAdapter
    extends TypeAdapter<RewardRedemptionStatus> {
  @override
  final int typeId = 25;

  @override
  RewardRedemptionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardRedemptionStatus.pending;
      case 1:
        return RewardRedemptionStatus.fulfilled;
      case 2:
        return RewardRedemptionStatus.cancelled;
      default:
        return RewardRedemptionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RewardRedemptionStatus obj) {
    switch (obj) {
      case RewardRedemptionStatus.pending:
        writer.writeByte(0);
        break;
      case RewardRedemptionStatus.fulfilled:
        writer.writeByte(1);
        break;
      case RewardRedemptionStatus.cancelled:
        writer.writeByte(2);
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

class RewardTodoStatusAdapter extends TypeAdapter<RewardTodoStatus> {
  @override
  final int typeId = 27;

  @override
  RewardTodoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardTodoStatus.pending;
      case 1:
        return RewardTodoStatus.completed;
      default:
        return RewardTodoStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RewardTodoStatus obj) {
    switch (obj) {
      case RewardTodoStatus.pending:
        writer.writeByte(0);
        break;
      case RewardTodoStatus.completed:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTodoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
