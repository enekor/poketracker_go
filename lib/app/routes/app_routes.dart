// lib/app/routes/app_routes.dart

import 'package:get/get.dart';
import 'package:poketracker_go/features/home/home_screen.dart';
import 'package:poketracker_go/features/pokedex/pokedex_screen.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String pokedex = '/pokedex';
  static const String pokemonSelector = '/pokemon-selector';
  static const String pokemonDetail = '/pokemon-detail';

  static List<GetPage> pages = [
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: pokedex, page: () => const PokedexScreen()),
    GetPage(name: pokemonSelector, page: () => const PokedexScreen()),
    GetPage(name: pokemonDetail, page: () => const PokemonDetailScreen()),
  ];
}
