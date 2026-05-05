// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 8;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      status: fields[3] as ProjectStatus?,
      startDate: fields[4] as DateTime?,
      endDate: fields[5] as DateTime?,
      color: fields[6] as String?,
      icon: fields[7] as String?,
      todoIds: (fields[8] as List?)?.cast<String>(),
      goalIds: (fields[9] as List?)?.cast<String>(),
      phases: (fields[10] as List?)?.cast<ProjectPhase>(),
      progress: fields[11] as double,
      tags: (fields[12] as List?)?.cast<String>(),
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
      notes: fields[15] as String?,
      metadata: (fields[16] as Map?)?.cast<String, dynamic>(),
      domainId: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.icon)
      ..writeByte(8)
      ..write(obj.todoIds)
      ..writeByte(9)
      ..write(obj.goalIds)
      ..writeByte(10)
      ..write(obj.phases)
      ..writeByte(11)
      ..write(obj.progress)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.metadata)
      ..writeByte(17)
      ..write(obj.domainId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectPhaseAdapter extends TypeAdapter<ProjectPhase> {
  @override
  final int typeId = 9;

  @override
  ProjectPhase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectPhase(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      progress: fields[5] as double,
      todoIds: (fields[6] as List?)?.cast<String>(),
      weight: fields[7] as double?,
      status: fields[8] as PhaseStatus?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectPhase obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.todoIds)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectPhaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final int typeId = 10;

  @override
  ProjectStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectStatus.planning;
      case 1:
        return ProjectStatus.active;
      case 2:
        return ProjectStatus.onHold;
      case 3:
        return ProjectStatus.completed;
      case 4:
        return ProjectStatus.cancelled;
      case 5:
        return ProjectStatus.archived;
      default:
        return ProjectStatus.planning;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    switch (obj) {
      case ProjectStatus.planning:
        writer.writeByte(0);
        break;
      case ProjectStatus.active:
        writer.writeByte(1);
        break;
      case ProjectStatus.onHold:
        writer.writeByte(2);
        break;
      case ProjectStatus.completed:
        writer.writeByte(3);
        break;
      case ProjectStatus.cancelled:
        writer.writeByte(4);
        break;
      case ProjectStatus.archived:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PhaseStatusAdapter extends TypeAdapter<PhaseStatus> {
  @override
  final int typeId = 11;

  @override
  PhaseStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PhaseStatus.pending;
      case 1:
        return PhaseStatus.active;
      case 2:
        return PhaseStatus.completed;
      case 3:
        return PhaseStatus.skipped;
      default:
        return PhaseStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PhaseStatus obj) {
    switch (obj) {
      case PhaseStatus.pending:
        writer.writeByte(0);
        break;
      case PhaseStatus.active:
        writer.writeByte(1);
        break;
      case PhaseStatus.completed:
        writer.writeByte(2);
        break;
      case PhaseStatus.skipped:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectHealthAdapter extends TypeAdapter<ProjectHealth> {
  @override
  final int typeId = 12;

  @override
  ProjectHealth read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectHealth.good;
      case 1:
        return ProjectHealth.atRisk;
      case 2:
        return ProjectHealth.critical;
      default:
        return ProjectHealth.good;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectHealth obj) {
    switch (obj) {
      case ProjectHealth.good:
        writer.writeByte(0);
        break;
      case ProjectHealth.atRisk:
        writer.writeByte(1);
        break;
      case ProjectHealth.critical:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectHealthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
