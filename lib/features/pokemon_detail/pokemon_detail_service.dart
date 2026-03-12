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
  final RxBool hasFemaleSprite = false.obs;

  @override
  void onInit() {
    super.onInit();
    final PokemonModel arg = Get.arguments as PokemonModel;
    _loadDetail(arg);
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
    } catch (e) {
      // Fallback to basic data
      pokemon.value = basicPokemon;
    } finally {
      isLoading.value = false;
    }
  }

  String capitalizedName() {
    final name = pokemon.value?.name ?? '';
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }
}
