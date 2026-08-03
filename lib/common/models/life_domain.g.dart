// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_domain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LifeDomainAdapter extends TypeAdapter<LifeDomain> {
  @override
  final int typeId = 14;

  @override
  LifeDomain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LifeDomain(
      id: fields[0] as String?,
      name: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LifeDomain obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeDomainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
