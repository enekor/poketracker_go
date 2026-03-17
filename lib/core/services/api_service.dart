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

  /// Fetches the evolution chain for a Pokémon by its ID.
  /// Returns a flat list of evolution stages (each stage = list of species).
  Future<List<List<EvolutionEntry>>> fetchEvolutionChain(int pokemonId) async {
    // 1. Get species to find evolution_chain URL
    final speciesUrl =
        Uri.parse('${ApiConstants.speciesEndpoint}/$pokemonId');
    final speciesResp = await http.get(speciesUrl);
    if (speciesResp.statusCode != 200) return [];

    final speciesData = json.decode(speciesResp.body);
    final chainUrl = speciesData['evolution_chain']?['url'] as String?;
    if (chainUrl == null) return [];

    // 2. Fetch the evolution chain
    final chainResp = await http.get(Uri.parse(chainUrl));
    if (chainResp.statusCode != 200) return [];

    final chainData = json.decode(chainResp.body);
    final chain = chainData['chain'] as Map<String, dynamic>?;
    if (chain == null) return [];

    // 3. Flatten the nested structure into stages
    return _flattenChain(chain);
  }

  List<List<EvolutionEntry>> _flattenChain(Map<String, dynamic> node) {
    final List<List<EvolutionEntry>> stages = [];
    List<Map<String, dynamic>> currentNodes = [node];

    while (currentNodes.isNotEmpty) {
      final List<EvolutionEntry> stage = [];
      final List<Map<String, dynamic>> nextNodes = [];

      for (final n in currentNodes) {
        final species = n['species'] as Map<String, dynamic>;
        final url = species['url'] as String;
        final id =
            int.parse(url.split('/').where((s) => s.isNotEmpty).last);
        stage.add(EvolutionEntry(id: id, name: species['name'] as String));

        final evolvesTo = n['evolves_to'] as List? ?? [];
        for (final child in evolvesTo) {
          nextNodes.add(child as Map<String, dynamic>);
        }
      }

      stages.add(stage);
      currentNodes = nextNodes;
    }

    return stages;
  }
}

class EvolutionEntry {
  final int id;
  final String name;

  const EvolutionEntry({required this.id, required this.name});
}
