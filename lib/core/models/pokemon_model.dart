// lib/core/models/pokemon_model.dart

import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/constants/pokemon_generations.dart';

class PokemonModel {
  final int id;
  final String name;
  final String spriteUrl;
  final String spriteShinyUrl;
  final List<String> types;
  final int generation;

  PokemonModel({
    required this.id,
    required this.name,
    required this.spriteUrl,
    required this.spriteShinyUrl,
    required this.types,
    required this.generation,
  });

  /// Creates a PokemonModel from a PokeAPI /pokemon/{id} JSON response.
  factory PokemonModel.fromPokeApi(Map<String, dynamic> json) {
    final int id = json['id'] as int;
    final List<String> types = (json['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    return PokemonModel(
      id: id,
      name: json['name'] as String,
      spriteUrl: ApiConstants.spriteUrl(id),
      spriteShinyUrl: ApiConstants.spriteShinyUrl(id),
      types: types,
      generation: getGeneration(id),
    );
  }

  /// Creates a minimal PokemonModel from the list endpoint (name + url only).
  factory PokemonModel.fromListEntry(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);

    return PokemonModel(
      id: id,
      name: json['name'] as String,
      spriteUrl: ApiConstants.spriteUrl(id),
      spriteShinyUrl: ApiConstants.spriteShinyUrl(id),
      types: [],
      generation: getGeneration(id),
    );
  }

  /// Formatted Pokédex number (e.g. #001)
  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}
