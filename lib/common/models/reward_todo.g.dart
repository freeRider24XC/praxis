// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardTodoAdapter extends TypeAdapter<RewardTodo> {
  @override
  final int typeId = 25;

  @override
  RewardTodo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardTodo(
      id: fields[0] as String?,
      redemptionId: fields[1] as String,
      title: fields[2] as String,
      notes: fields[3] as String?,
      status: fields[4] as RewardTodoStatus?,
      dueDate: fields[5] as DateTime?,
      completedAt: fields[6] as DateTime?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardTodo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.redemptionId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
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

class RewardTodoStatusAdapter extends TypeAdapter<RewardTodoStatus> {
  @override
  final int typeId = 24;

  @override
  RewardTodoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardTodoStatus.pending;
      case 1:
        return RewardTodoStatus.completed;
      case 2:
        return RewardTodoStatus.expired;
      case 3:
        return RewardTodoStatus.cancelled;
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
      case RewardTodoStatus.expired:
        writer.writeByte(2);
        break;
      case RewardTodoStatus.cancelled:
        writer.writeByte(3);
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
