// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_pokemon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPokemonModelAdapter extends TypeAdapter<UserPokemonModel> {
  @override
  final int typeId = 0;

  @override
  UserPokemonModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPokemonModel(
      pokemonId: fields[0] as int,
      hasNormal: fields[1] as bool,
      hasShiny: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserPokemonModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pokemonId)
      ..writeByte(1)
      ..write(obj.hasNormal)
      ..writeByte(2)
      ..write(obj.hasShiny);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPokemonModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
