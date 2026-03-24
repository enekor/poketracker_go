// lib/features/home/home_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/services/hive_service.dart';
import 'package:poketracker_go/features/calendar/calendar_service.dart';

class HomeService extends GetxController {
  final HiveService _hiveService = Get.find<HiveService>();

  final RxInt totalOwned = 0.obs;
  final RxInt totalShiny = 0.obs;
  final int totalPokemon = ApiConstants.totalPokemon;

  final activeEvents = <PogoEvent>[].obs;
  final isLoadingEvents = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshStats();
    loadActiveEvents();
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

  Future<void> loadActiveEvents() async {
    isLoadingEvents.value = true;
    try {
      final resp = await http.get(Uri.parse(ApiConstants.eventsUrl));
      if (resp.statusCode == 200) {
        final list = json.decode(resp.body) as List;
        final allEvents = list.map((e) => PogoEvent.fromJson(e)).toList();

        // Load hidden filters from Hive
        final saved =
            _hiveService.calendarFiltersBox.get('hiddenEventTypes');
        final hidden =
            saved is List ? saved.cast<String>().toSet() : <String>{};

        activeEvents.value = allEvents
            .where((e) => e.isActive && !hidden.contains(e.heading))
            .toList();
      }
    } catch (_) {}
    isLoadingEvents.value = false;
  }
}
