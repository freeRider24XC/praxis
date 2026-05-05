// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime?,
      dueDate: fields[4] as DateTime?,
      isDone: fields[5] as bool?,
      priority: fields[6] as TodoPriority?,
      tags: (fields[7] as List?)?.cast<String>(),
      projectId: fields[8] as String?,
      goalId: fields[9] as String?,
      completedAt: fields[10] as DateTime?,
      reminderTime: fields[11] as DateTime?,
      subTasks: (fields[12] as List?)?.cast<String>(),
      parentId: fields[13] as String?,
      recurrence: fields[14] as RecurrenceRule?,
      updatedAt: fields[15] as DateTime?,
      domainId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.isDone)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.projectId)
      ..writeByte(9)
      ..write(obj.goalId)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.reminderTime)
      ..writeByte(12)
      ..write(obj.subTasks)
      ..writeByte(13)
      ..write(obj.parentId)
      ..writeByte(14)
      ..write(obj.recurrence)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.domainId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = 2;

  @override
  RecurrenceRule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurrenceRule(
      type: fields[0] as RecurrenceType,
      interval: fields[1] as int,
      daysOfWeek: (fields[2] as List?)?.cast<int>(),
      dayOfMonth: fields[3] as int?,
      endDate: fields[4] as DateTime?,
      occurrences: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.interval)
      ..writeByte(2)
      ..write(obj.daysOfWeek)
      ..writeByte(3)
      ..write(obj.dayOfMonth)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.occurrences);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceRuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoPriorityAdapter extends TypeAdapter<TodoPriority> {
  @override
  final int typeId = 1;

  @override
  TodoPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoPriority.low;
      case 1:
        return TodoPriority.medium;
      case 2:
        return TodoPriority.high;
      case 3:
        return TodoPriority.urgent;
      default:
        return TodoPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TodoPriority obj) {
    switch (obj) {
      case TodoPriority.low:
        writer.writeByte(0);
        break;
      case TodoPriority.medium:
        writer.writeByte(1);
        break;
      case TodoPriority.high:
        writer.writeByte(2);
        break;
      case TodoPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 3;

  @override
  RecurrenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceType.daily;
      case 1:
        return RecurrenceType.weekly;
      case 2:
        return RecurrenceType.monthly;
      case 3:
        return RecurrenceType.yearly;
      default:
        return RecurrenceType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    switch (obj) {
      case RecurrenceType.daily:
        writer.writeByte(0);
        break;
      case RecurrenceType.weekly:
        writer.writeByte(1);
        break;
      case RecurrenceType.monthly:
        writer.writeByte(2);
        break;
      case RecurrenceType.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
