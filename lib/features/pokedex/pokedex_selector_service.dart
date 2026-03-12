// lib/features/pokedex/pokedex_selector_service.dart

import 'package:get/get.dart';
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
      final userEntry = userData[p.id];
      map[p.id] = currentPage.value == 1
          ? (userEntry?.hasShiny ?? false)
          : (userEntry?.hasNormal ?? false);
    }
    selection.assignAll(map);
    _originalSelection
      ..clear()
      ..addAll(map);
  }

  void toggleMode(int newMode) {
    currentPage.value = newMode;
    _initSelection();
  }

  void togglePokemon(int pokemonId) {
    selection[pokemonId] = !(selection[pokemonId] ?? false);
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
    final isShiny = currentPage.value == 1;
    final models = <UserPokemonModel>[];
    for (final entry in selection.entries) {
      final existing = hiveService.getUserPokemon(entry.key);
      models.add(UserPokemonModel(
        pokemonId: entry.key,
        hasNormal: isShiny ? (existing?.hasNormal ?? false) : entry.value,
        hasShiny: isShiny ? entry.value : (existing?.hasShiny ?? false),
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
