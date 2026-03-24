// lib/features/home/home_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/services/hive_service.dart';
import 'package:poketracker_go/features/calendar/calendar_service.dart';

class HomeService extends GetxController {
  final HiveService _hiveService = Get.find<HiveService>();
  final SpriteStyleController _spriteCtrl = Get.find<SpriteStyleController>();

  final RxInt totalOwned = 0.obs;
  final RxInt totalShiny = 0.obs;
  final int totalPokemon = ApiConstants.totalPokemon;

  final activeEvents = <PogoEvent>[].obs;
  final missingPokemon = <MissingPokemon>[].obs;
  final isLoadingEvents = true.obs;
  final isLoadingMissing = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshStats();
    _loadAll();
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

  Future<void> _loadAll() async {
    await Future.wait([
      loadActiveEvents(),
      _loadMissingPokemon(),
    ]);
  }

  Future<void> loadActiveEvents() async {
    isLoadingEvents.value = true;
    try {
      final resp = await http.get(Uri.parse(ApiConstants.eventsUrl));
      if (resp.statusCode == 200) {
        final list = json.decode(resp.body) as List;
        final allEvents = list.map((e) => PogoEvent.fromJson(e)).toList();

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

  Future<void> _loadMissingPokemon() async {
    isLoadingMissing.value = true;
    try {
      final results = await Future.wait([
        http.get(Uri.parse(ApiConstants.researchUrl)),
        http.get(Uri.parse(ApiConstants.raidsUrl)),
      ]);

      final userPokemon = _hiveService.getAllUserPokemon();
      final seen = <String>{};
      final missing = <MissingPokemon>[];

      void check({
        required String name,
        required String imageUrl,
        required bool canBeShiny,
      }) {
        final id = _extractPokemonId(imageUrl);
        if (id == null || id > ApiConstants.totalPokemon) return;

        final userData = userPokemon[id];
        final hasNormal = userData?.hasNormal ?? false;
        final hasShiny = userData?.hasShiny ?? false;

        if (!hasNormal && seen.add('$id-normal')) {
          missing.add(MissingPokemon(
            id: id,
            name: name,
            image: _spriteCtrl.spriteUrl(id),
            isShiny: false,
          ));
        }
        if (canBeShiny && !hasShiny && seen.add('$id-shiny')) {
          missing.add(MissingPokemon(
            id: id,
            name: name,
            image: _spriteCtrl.spriteShinyUrl(id),
            isShiny: true,
          ));
        }
      }

      // Research rewards
      if (results[0].statusCode == 200) {
        final list = json.decode(results[0].body) as List;
        for (final task in list) {
          for (final r in (task['rewards'] as List? ?? [])) {
            check(
              name: r['name'] ?? '',
              imageUrl: r['image'] ?? '',
              canBeShiny: r['canBeShiny'] ?? false,
            );
          }
        }
      }

      // Raids
      if (results[1].statusCode == 200) {
        final list = json.decode(results[1].body) as List;
        for (final r in list) {
          check(
            name: r['name'] ?? '',
            imageUrl: r['image'] ?? '',
            canBeShiny: r['canBeShiny'] ?? false,
          );
        }
      }

      missingPokemon.value = missing;
    } catch (_) {}
    isLoadingMissing.value = false;
  }

  /// Extracts the Pokémon ID from a LeekDuck image URL.
  /// URLs look like: .../pm412.fBURMY_PLANT.icon.png or .../pm1.icon.png
  static int? _extractPokemonId(String url) {
    final match = RegExp(r'pm(\d+)').firstMatch(url);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}

/// A Pokémon the user is missing that is currently available in-game.
class MissingPokemon {
  final int id;
  final String name;
  final String image;
  final bool isShiny;

  const MissingPokemon({
    required this.id,
    required this.name,
    required this.image,
    required this.isShiny,
  });
}
