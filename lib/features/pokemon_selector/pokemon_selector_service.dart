// lib/features/pokemon_selector/pokemon_selector_service.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:poketracker_go/core/constants/pokemon_generations.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/core/services/api_service.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class PokemonSelectorService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final HiveService _hiveService = Get.find<HiveService>();

  final RxList<PokemonModel> allPokemon = <PokemonModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt mode = 0.obs; // 0 = Normal, 1 = Shiny
  final RxString searchQuery = ''.obs;
  final RxInt selectedGeneration = 0.obs;

  /// Temporary selection state: pokemonId -> selected
  final RxMap<int, bool> selection = <int, bool>{}.obs;

  /// Original selection state to detect changes.
  final Map<int, bool> _originalSelection = {};

  Timer? _debounce;

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
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final pokemon = await _apiService.fetchAllPokemon();
      allPokemon.assignAll(pokemon);
      _initSelection();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los Pokémon: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Whether the current selection differs from the saved state.
  bool get hasChanges {
    for (final entry in selection.entries) {
      if (entry.value != (_originalSelection[entry.key] ?? false)) {
        return true;
      }
    }
    return false;
  }

  /// Initialize selection from current Hive data.
  void _initSelection() {
    final userData = _hiveService.getAllUserPokemon();
    final map = <int, bool>{};
    for (final p in allPokemon) {
      final userEntry = userData[p.id];
      if (mode.value == 0) {
        map[p.id] = userEntry?.hasNormal ?? false;
      } else {
        map[p.id] = userEntry?.hasShiny ?? false;
      }
    }
    selection.assignAll(map);
    _originalSelection
      ..clear()
      ..addAll(map);
  }

  void toggleMode(int newMode) {
    mode.value = newMode;
    _initSelection();
  }

  void togglePokemon(int pokemonId) {
    selection[pokemonId] = !(selection[pokemonId] ?? false);
    selection.refresh();
  }

  bool isSelected(int pokemonId) {
    return selection[pokemonId] ?? false;
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

  /// Save all changes to Hive.
  Future<void> saveSelection() async {
    final models = <UserPokemonModel>[];
    for (final entry in selection.entries) {
      final existing = _hiveService.getUserPokemon(entry.key);
      final hasNormal = mode.value == 0 ? entry.value : (existing?.hasNormal ?? false);
      final hasShiny = mode.value == 1 ? entry.value : (existing?.hasShiny ?? false);
      models.add(UserPokemonModel(
        pokemonId: entry.key,
        hasNormal: hasNormal,
        hasShiny: hasShiny,
      ));
    }
    await _hiveService.saveAllUserPokemon(models);
    _originalSelection
      ..clear()
      ..addAll(Map.from(selection));
    selection.refresh();
    Get.snackbar('Guardado', 'Cambios guardados correctamente');
  }
}
