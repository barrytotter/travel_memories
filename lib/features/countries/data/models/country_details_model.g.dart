// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_details_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryDetailsModelAdapter extends TypeAdapter<CountryDetailsModel> {
  @override
  final typeId = 1;

  @override
  CountryDetailsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryDetailsModel(
      countryCode: fields[0] as String,
      isVisited: fields[1] as bool,
      foodRating: (fields[2] as num?)?.toDouble(),
      entertainmentRating: (fields[3] as num?)?.toDouble(),
      natureRating: (fields[4] as num?)?.toDouble(),
      comfortRating: (fields[5] as num?)?.toDouble(),
      priceRating: (fields[6] as num?)?.toDouble(),
      visitedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CountryDetailsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.countryCode)
      ..writeByte(1)
      ..write(obj.isVisited)
      ..writeByte(2)
      ..write(obj.foodRating)
      ..writeByte(3)
      ..write(obj.entertainmentRating)
      ..writeByte(4)
      ..write(obj.natureRating)
      ..writeByte(5)
      ..write(obj.comfortRating)
      ..writeByte(6)
      ..write(obj.priceRating)
      ..writeByte(7)
      ..write(obj.visitedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryDetailsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
