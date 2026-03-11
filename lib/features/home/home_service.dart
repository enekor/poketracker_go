// lib/features/home/home_service.dart

import 'package:get/get.dart';
import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class HomeService extends GetxController {
  final HiveService _hiveService = Get.find<HiveService>();

  final RxInt totalOwned = 0.obs;
  final RxInt totalShiny = 0.obs;
  final int totalPokemon = ApiConstants.totalPokemon;

  @override
  void onInit() {
    super.onInit();
    refreshStats();
  }

  void refreshStats() {
    final allUserPokemon = _hiveService.getAllUserPokemon();
    int normal = 0;
    int shiny = 0;
    for (final entry in allUserPokemon.values) {
      if (entry.hasNormal) normal++;
      if (entry.hasShiny) shiny++;
    }
    totalOwned.value = normal;
    totalShiny.value = shiny;
  }
}
