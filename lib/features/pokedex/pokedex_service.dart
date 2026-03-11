// lib/features/pokedex/pokedex_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/core/constants/pokemon_generations.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/core/services/api_service.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class PokedexService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final HiveService _hiveService = Get.find<HiveService>();

  final RxList<PokemonModel> allPokemon = <PokemonModel>[].obs;
  final RxMap<int, UserPokemonModel> userPokemon = <int, UserPokemonModel>{}.obs;
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 0.obs; // 0 = Normal, 1 = Shiny
  final RxString searchQuery = ''.obs;
  final RxInt selectedGeneration = 0.obs; // 0 = all

  /// Scroll controllers for normal and shiny grids.
  final ScrollController normalScrollController = ScrollController();
  final ScrollController shinyScrollController = ScrollController();

  /// PageController for the Normal/Shiny swipe.
  final PageController pageController = PageController();

  Timer? _debounce;

  /// Computed list of generation groups for the grid.
  List<MapEntry<int, List<PokemonModel>>> get pokemonByGeneration {
    final filtered = _filteredPokemon;
    final Map<int, List<PokemonModel>> groups = {};
    for (final p in filtered) {
      groups.putIfAbsent(p.generation, () => []).add(p);
    }
    final sorted = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  List<PokemonModel> get _filteredPokemon {
    var list = allPokemon.toList();

    if (selectedGeneration.value > 0) {
      list = list.where((p) => p.generation == selectedGeneration.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase().replaceAll('#', '');
      final asInt = int.tryParse(q);
      if (asInt != null) {
        list = list.where((p) => p.id == asInt).toList();
      } else {
        list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
      }
    }

    return list;
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _syncScrollControllers();
  }

  @override
  void onClose() {
    normalScrollController.dispose();
    shinyScrollController.dispose();
    pageController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final pokemon = await _apiService.fetchAllPokemon();
      allPokemon.assignAll(pokemon);
      userPokemon.assignAll(_hiveService.getAllUserPokemon());
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los Pokémon: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _syncScrollControllers() {
    normalScrollController.addListener(() {
      if (currentPage.value == 0 && shinyScrollController.hasClients) {
        shinyScrollController.jumpTo(normalScrollController.offset);
      }
    });
    shinyScrollController.addListener(() {
      if (currentPage.value == 1 && normalScrollController.hasClients) {
        normalScrollController.jumpTo(shinyScrollController.offset);
      }
    });
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
    });
  }

  void selectGeneration(int gen) {
    selectedGeneration.value = gen;
  }

  bool hasNormal(int pokemonId) {
    return userPokemon[pokemonId]?.hasNormal ?? false;
  }

  bool hasShiny(int pokemonId) {
    return userPokemon[pokemonId]?.hasShiny ?? false;
  }

  void refreshUserData() {
    userPokemon.assignAll(_hiveService.getAllUserPokemon());
  }
}
