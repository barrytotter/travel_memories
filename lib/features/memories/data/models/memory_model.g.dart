// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryModelAdapter extends TypeAdapter<MemoryModel> {
  @override
  final typeId = 2;

  @override
  MemoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryModel(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      category: fields[2] as String,
      description: fields[3] as String,
      createdAt: fields[4] as DateTime,
      latitude: (fields[5] as num?)?.toDouble(),
      longitude: (fields[6] as num?)?.toDouble(),
      countryIso: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.countryIso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
