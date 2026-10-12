// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_schedule_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoScheduleSlotAdapter extends TypeAdapter<TodoScheduleSlot> {
  @override
  final int typeId = 26;

  @override
  TodoScheduleSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoScheduleSlot(
      id: fields[0] as String?,
      todoId: fields[1] as String,
      scheduledDate: fields[2] as DateTime,
      scheduledStart: fields[3] as DateTime?,
      scheduledEnd: fields[4] as DateTime?,
      status: fields[5] as ScheduleSlotStatus?,
      source: fields[6] as ScheduleSlotSource?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TodoScheduleSlot obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.todoId)
      ..writeByte(2)
      ..write(obj.scheduledDate)
      ..writeByte(3)
      ..write(obj.scheduledStart)
      ..writeByte(4)
      ..write(obj.scheduledEnd)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.source)
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
      other is TodoScheduleSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleSlotStatusAdapter extends TypeAdapter<ScheduleSlotStatus> {
  @override
  final int typeId = 27;

  @override
  ScheduleSlotStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleSlotStatus.scheduled;
      case 1:
        return ScheduleSlotStatus.completed;
      case 2:
        return ScheduleSlotStatus.skipped;
      default:
        return ScheduleSlotStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleSlotStatus obj) {
    switch (obj) {
      case ScheduleSlotStatus.scheduled:
        writer.writeByte(0);
        break;
      case ScheduleSlotStatus.completed:
        writer.writeByte(1);
        break;
      case ScheduleSlotStatus.skipped:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleSlotStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleSlotSourceAdapter extends TypeAdapter<ScheduleSlotSource> {
  @override
  final int typeId = 28;

  @override
  ScheduleSlotSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleSlotSource.ai;
      case 1:
        return ScheduleSlotSource.manual;
      default:
        return ScheduleSlotSource.ai;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleSlotSource obj) {
    switch (obj) {
      case ScheduleSlotSource.ai:
        writer.writeByte(0);
        break;
      case ScheduleSlotSource.manual:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleSlotSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
