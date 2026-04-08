// lib/features/pokemon_detail/pokemon_detail_service.dart

import 'package:get/get.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/core/services/api_service.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class PokemonDetailService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final HiveService _hiveService = Get.find<HiveService>();

  final Rx<PokemonModel?> pokemon = Rx<PokemonModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasNormal = false.obs;
  final RxBool hasShiny = false.obs;
  final RxBool hasShadow = false.obs;
  final RxBool hasPurified = false.obs;
  final RxBool hasShadowShiny = false.obs;
  final RxBool hasPurifiedShiny = false.obs;
  final RxBool hasFemaleSprite = false.obs;
  final RxList<List<EvolutionEntry>> evolutionChain =
      <List<EvolutionEntry>>[].obs;
  final RxBool isLoadingEvolution = true.obs;

  @override
  void onInit() {
    super.onInit();
    final PokemonModel arg = Get.arguments as PokemonModel;
    loadPokemon(arg.id, arg.name);
  }

  /// Loads a new Pokémon into this screen (used for evolution chain navigation).
  void loadPokemon(int id, String name) {
    final basicPokemon = PokemonModel(
      id: id,
      name: name,
      spriteUrl: '',
      spriteShinyUrl: '',
      types: [],
      generation: 0,
    );
    _loadDetail(basicPokemon);
  }

  Future<void> _loadDetail(PokemonModel basicPokemon) async {
    try {
      isLoading.value = true;
      // Fetch full detail (with types)
      final detail = await _apiService.fetchPokemonDetail(basicPokemon.id);
      pokemon.value = detail;
      hasFemaleSprite.value = detail.hasFemaleSprite;

      // Load user ownership
      final userEntry = _hiveService.getUserPokemon(basicPokemon.id);
      hasNormal.value = userEntry?.hasNormal ?? false;
      hasShiny.value = userEntry?.hasShiny ?? false;
      hasShadow.value = userEntry?.hasShadow ?? false;
      hasPurified.value = userEntry?.hasPurified ?? false;
      hasShadowShiny.value = userEntry?.hasShadowShiny ?? false;
      hasPurifiedShiny.value = userEntry?.hasPurifiedShiny ?? false;
    } catch (e) {
      // Fallback to basic data
      pokemon.value = basicPokemon;
    } finally {
      isLoading.value = false;
    }

    // Load evolution chain (non-blocking)
    _loadEvolutionChain(basicPokemon.id);
  }

  Future<void> _loadEvolutionChain(int pokemonId) async {
    try {
      isLoadingEvolution.value = true;
      final chain = await _apiService.fetchEvolutionChain(pokemonId);
      evolutionChain.assignAll(chain);
    } catch (_) {
      // Silently fail — evolution chain is optional
    } finally {
      isLoadingEvolution.value = false;
    }
  }

  String capitalizedName() {
    final name = pokemon.value?.name ?? '';
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }
}
