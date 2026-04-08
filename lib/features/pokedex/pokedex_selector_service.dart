// lib/features/pokedex/pokedex_selector_service.dart

import 'package:get/get.dart';
import 'package:poketracker_go/core/constants/pokemon_generations.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/features/pokedex/pokedex_base_service.dart';

/// Selection mode: pick Pokémon to register as owned, then save.
class PokedexSelectorService extends PokedexBaseService {
  final RxMap<int, bool> selection = <int, bool>{}.obs;
  final Map<int, bool> _originalSelection = {};

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onDataLoaded() {
    _initSelection();
  }

  @override
  bool isOwned(int pokemonId) => selection[pokemonId] == true;

  // ─── Selection ───

  void _initSelection() {
    final userData = hiveService.getAllUserPokemon();
    final map = <int, bool>{};
    for (final p in allPokemon) {
      final u = userData[p.id];
      map[p.id] = _getVariant(u, currentPage.value);
    }
    selection.assignAll(map);
    _originalSelection
      ..clear()
      ..addAll(map);
  }

  static bool _getVariant(UserPokemonModel? u, int page) {
    if (u == null) return false;
    switch (page) {
      case 0: return u.hasNormal;
      case 1: return u.hasShiny;
      case 2: return u.hasShadow;
      case 3: return u.hasPurified;
      case 4: return u.hasShadowShiny;
      case 5: return u.hasPurifiedShiny;
      default: return false;
    }
  }

  void toggleMode(int newMode) {
    currentPage.value = newMode;
    _initSelection();
  }

  void togglePokemon(int pokemonId) {
    selection[pokemonId] = !(selection[pokemonId] ?? false);
    selection.refresh();
  }

  void selectAllInGeneration(int generation) {
    final genData = pokemonGenerations[generation];
    if (genData == null) return;

    final start = genData['start'] as int;
    final end = genData['end'] as int;

    bool allSelected = true;
    for (int i = start; i <= end; i++) {
        if (selection[i] != true) {
            allSelected = false;
            break;
        }
    }

    final targetValue = !allSelected;
    for (int i = start; i <= end; i++) {
        selection[i] = targetValue;
    }
    selection.refresh();
  }

  bool isSelected(int pokemonId) => selection[pokemonId] ?? false;

  bool get hasChanges {
    for (final entry in selection.entries) {
      if (entry.value != (_originalSelection[entry.key] ?? false)) {
        return true;
      }
    }
    return false;
  }

  Future<void> saveSelection() async {
    final page = currentPage.value;
    final models = <UserPokemonModel>[];
    for (final entry in selection.entries) {
      final existing = hiveService.getUserPokemon(entry.key);
      models.add(UserPokemonModel(
        pokemonId: entry.key,
        hasNormal: page == 0 ? entry.value : (existing?.hasNormal ?? false),
        hasShiny: page == 1 ? entry.value : (existing?.hasShiny ?? false),
        hasShadow: page == 2 ? entry.value : (existing?.hasShadow ?? false),
        hasPurified: page == 3 ? entry.value : (existing?.hasPurified ?? false),
        hasShadowShiny: page == 4 ? entry.value : (existing?.hasShadowShiny ?? false),
        hasPurifiedShiny: page == 5 ? entry.value : (existing?.hasPurifiedShiny ?? false),
      ));
    }
    await hiveService.saveAllUserPokemon(models);
    _originalSelection
      ..clear()
      ..addAll(Map.from(selection));
    selection.refresh();
    Get.snackbar('Guardado', 'Cambios guardados correctamente');
  }
}
