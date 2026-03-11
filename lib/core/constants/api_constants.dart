// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const String pokemonEndpoint = '$baseUrl/pokemon';
  static const String speciesEndpoint = '$baseUrl/pokemon-species';

  /// Sprite URL templates
  static String spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  static String spriteShinyUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png';

  /// Total number of Pokémon supported
  static const int totalPokemon = 1025;
}
