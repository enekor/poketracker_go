// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const String pokemonEndpoint = '$baseUrl/pokemon';
  static const String speciesEndpoint = '$baseUrl/pokemon-species';

  /// Sprite URL templates — pixel art (default front sprites)
  static String spriteUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  static String spriteShinyUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png';

  /// Sprite URL templates — 3D (Pokémon HOME renders)
  static String spriteHomeUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png';

  static String spriteHomeShinyUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/$id.png';

  /// Total number of Pokémon supported
  static const int totalPokemon = 1025;

  /// ScrapedDuck data endpoints (raw GitHub)
  static const String _scrapedDuckBase =
      'https://raw.githubusercontent.com/bigfoott/ScrapedDuck/data';
  static const String eventsUrl = '$_scrapedDuckBase/events.min.json';
  static const String raidsUrl = '$_scrapedDuckBase/raids.min.json';
  static const String eggsUrl = '$_scrapedDuckBase/eggs.min.json';
  static const String researchUrl = '$_scrapedDuckBase/research.min.json';
  static const String rocketUrl = '$_scrapedDuckBase/rocketLineups.min.json';
}
