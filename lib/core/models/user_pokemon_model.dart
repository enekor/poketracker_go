// lib/core/models/user_pokemon_model.dart

import 'package:hive/hive.dart';

part 'user_pokemon_model.g.dart';

@HiveType(typeId: 0)
class UserPokemonModel extends HiveObject {
  @HiveField(0)
  final int pokemonId;

  @HiveField(1)
  bool hasNormal;

  @HiveField(2)
  bool hasShiny;

  UserPokemonModel({
    required this.pokemonId,
    this.hasNormal = false,
    this.hasShiny = false,
  });
}
