// lib/core/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';

class ApiService {
  /// Fetches the full list of Pokémon (id, name, sprites) from the PokeAPI
  /// list endpoint. Returns minimal PokemonModels (no types/stats).
  Future<List<PokemonModel>> fetchAllPokemon() async {
    final url = Uri.parse(
      '${ApiConstants.pokemonEndpoint}?limit=${ApiConstants.totalPokemon}&offset=0',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon list: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final results = data['results'] as List;

    return results.map((e) => PokemonModel.fromListEntry(e)).toList();
  }

  /// Fetches detailed data for a single Pokémon by ID.
  Future<PokemonModel> fetchPokemonDetail(int id) async {
    final url = Uri.parse('${ApiConstants.pokemonEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon #$id: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    return PokemonModel.fromPokeApi(data);
  }
}
