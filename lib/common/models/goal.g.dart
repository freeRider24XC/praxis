// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 4;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as GoalType,
      startDate: fields[4] as DateTime?,
      targetDate: fields[5] as DateTime,
      status: fields[6] as GoalStatus?,
      progress: fields[7] as double,
      category: fields[8] as String?,
      milestones: (fields[9] as List?)?.cast<String>(),
      keyResults: (fields[10] as List?)?.cast<KeyResult>(),
      parentGoalId: fields[11] as String?,
      subGoalIds: (fields[12] as List?)?.cast<String>(),
      linkedTodoIds: (fields[13] as List?)?.cast<String>(),
      createdAt: fields[14] as DateTime?,
      updatedAt: fields[15] as DateTime?,
      notes: fields[16] as String?,
      targetValue: fields[17] as int?,
      currentValue: fields[18] as int?,
      unit: fields[19] as String?,
      projectIds: (fields[20] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.targetDate)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.milestones)
      ..writeByte(10)
      ..write(obj.keyResults)
      ..writeByte(11)
      ..write(obj.parentGoalId)
      ..writeByte(12)
      ..write(obj.subGoalIds)
      ..writeByte(13)
      ..write(obj.linkedTodoIds)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.targetValue)
      ..writeByte(18)
      ..write(obj.currentValue)
      ..writeByte(19)
      ..write(obj.unit)
      ..writeByte(20)
      ..write(obj.projectIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KeyResultAdapter extends TypeAdapter<KeyResult> {
  @override
  final int typeId = 5;

  @override
  KeyResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyResult(
      id: fields[0] as String?,
      title: fields[1] as String,
      progress: fields[2] as double,
      targetValue: fields[3] as int?,
      currentValue: fields[4] as int?,
      unit: fields[5] as String?,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, KeyResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.targetValue)
      ..writeByte(4)
      ..write(obj.currentValue)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 6;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.yearly;
      case 1:
        return GoalType.quarterly;
      case 2:
        return GoalType.monthly;
      case 3:
        return GoalType.weekly;
      case 4:
        return GoalType.custom;
      default:
        return GoalType.yearly;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.yearly:
        writer.writeByte(0);
        break;
      case GoalType.quarterly:
        writer.writeByte(1);
        break;
      case GoalType.monthly:
        writer.writeByte(2);
        break;
      case GoalType.weekly:
        writer.writeByte(3);
        break;
      case GoalType.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final int typeId = 7;

  @override
  GoalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalStatus.notStarted;
      case 1:
        return GoalStatus.inProgress;
      case 2:
        return GoalStatus.paused;
      case 3:
        return GoalStatus.completed;
      case 4:
        return GoalStatus.cancelled;
      default:
        return GoalStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    switch (obj) {
      case GoalStatus.notStarted:
        writer.writeByte(0);
        break;
      case GoalStatus.inProgress:
        writer.writeByte(1);
        break;
      case GoalStatus.paused:
        writer.writeByte(2);
        break;
      case GoalStatus.completed:
        writer.writeByte(3);
        break;
      case GoalStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
