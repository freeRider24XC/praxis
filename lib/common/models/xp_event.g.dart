// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_event.dart';

class XpEventAdapter extends TypeAdapter<XpEvent> {
  @override
  final int typeId = 16;

  @override
  XpEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return XpEvent(
      id: fields[0] as String?,
      xp: fields[1] as int,
      source: fields[2] as String,
      sourceId: fields[3] as String,
      domainId: fields[4] as String?,
      description: fields[5] as String,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, XpEvent obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.xp)
      ..writeByte(2)
      ..write(obj.source)
      ..writeByte(3)
      ..write(obj.sourceId)
      ..writeByte(4)
      ..write(obj.domainId)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XpEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
