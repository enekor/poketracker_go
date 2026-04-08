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

  @HiveField(3)
  bool hasShadow;

  @HiveField(4)
  bool hasPurified;

  @HiveField(5)
  bool hasShadowShiny;

  @HiveField(6)
  bool hasPurifiedShiny;

  UserPokemonModel({
    required this.pokemonId,
    this.hasNormal = false,
    this.hasShiny = false,
    this.hasShadow = false,
    this.hasPurified = false,
    this.hasShadowShiny = false,
    this.hasPurifiedShiny = false,
  });
}
