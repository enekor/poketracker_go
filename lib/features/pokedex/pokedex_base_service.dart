// lib/features/pokedex/pokedex_base_service.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/core/services/api_service.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

/// Shared interface that both the view and selector services implement.
/// Contains all filtering, search, and generation logic.
abstract class PokedexBaseService extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final HiveService hiveService = Get.find<HiveService>();

  final RxList<PokemonModel> allPokemon = <PokemonModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt currentPage = 0.obs; // 0 = Normal, 1 = Shiny
  final RxString searchQuery = ''.obs;
  final RxInt selectedGeneration = 0.obs;
  final RxInt ownershipFilter = 0.obs;

  Timer? _debounce;

  // ─── Abstract ───

  /// Whether a Pokémon counts as "owned" for the ownership filter.
  bool isOwned(int pokemonId);

  // ─── Lifecycle ───

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final pokemon = await apiService.fetchAllPokemon();
      allPokemon.assignAll(pokemon);
      onDataLoaded();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los Pokémon: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Hook called after data is loaded. Override to add extra init.
  void onDataLoaded() {}

  // ─── Filtering ───

  List<MapEntry<int, List<PokemonModel>>> get pokemonByGeneration {
    final filtered = filteredPokemon;
    final Map<int, List<PokemonModel>> groups = {};
    for (final p in filtered) {
      groups.putIfAbsent(p.generation, () => []).add(p);
    }
    return groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  List<PokemonModel> get filteredPokemon {
    var list = allPokemon.toList();

    if (selectedGeneration.value > 0) {
      list =
          list.where((p) => p.generation == selectedGeneration.value).toList();
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

    if (ownershipFilter.value == 1) {
      list = list.where((p) => isOwned(p.id)).toList();
    } else if (ownershipFilter.value == 2) {
      list = list.where((p) => !isOwned(p.id)).toList();
    }

    return list;
  }

  // ─── UI actions ───

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
    });
  }

  void selectGeneration(int gen) => selectedGeneration.value = gen;

  void selectOwnershipFilter(int filter) => ownershipFilter.value = filter;
}
