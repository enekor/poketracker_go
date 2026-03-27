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
    await Future.wait([loadActiveEvents(), _loadMissingPokemon()]);
  }

  Future<void> loadActiveEvents() async {
    isLoadingEvents.value = true;
    try {
      final resp = await http.get(Uri.parse(ApiConstants.eventsUrl));
      if (resp.statusCode == 200) {
        final list = json.decode(resp.body) as List;
        final allEvents = list.map((e) => PogoEvent.fromJson(e)).toList();

        final saved = _hiveService.calendarFiltersBox.get('hiddenEventTypes');
        final hidden = saved is List
            ? saved.cast<String>().toSet()
            : <String>{};

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
          missing.add(
            MissingPokemon(
              id: id,
              name: name,
              image: _spriteCtrl.spriteUrl(id),
              isShiny: false,
            ),
          );
        }
        if (canBeShiny && !hasShiny && seen.add('$id-shiny')) {
          missing.add(
            MissingPokemon(
              id: id,
              name: name,
              image: _spriteCtrl.spriteShinyUrl(id),
              isShiny: true,
            ),
          );
        }
      }

      // Raids
      if (results[0].statusCode == 200) {
        final list = json.decode(results[0].body) as List;
        for (final r in list) {
          check(
            name: r['name'] ?? '',
            imageUrl: r['image'] ?? '',
            canBeShiny: r['canBeShiny'] ?? false,
          );
        }
      }

      // Event spawns from active events
      await _loadEventSpawns(check);

      missingPokemon.value = missing;
    } catch (_) {}
    isLoadingMissing.value = false;
  }

  /// Loads spawn pokemon from active events.
  /// For events with spawn data in JSON (community day / raid battles), uses it directly.
  /// For events with hasSpawns=true but no data, scrapes the LeekDuck page.
  Future<void> _loadEventSpawns(
    void Function({
      required String name,
      required String imageUrl,
      required bool canBeShiny,
    }) check,
  ) async {
    // Wait until activeEvents are loaded
    while (isLoadingEvents.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    for (final event in activeEvents) {
      // Use spawn data from JSON if available
      if (event.eventSpawns.isNotEmpty) {
        for (final spawn in event.eventSpawns) {
          check(
            name: spawn.name,
            imageUrl: spawn.image,
            canBeShiny: spawn.canBeShiny,
          );
        }
      } else if (event.hasSpawns && event.link.isNotEmpty) {
        // Scrape LeekDuck page for spawn pokemon
        await _scrapeEventSpawns(event.link, check);
      }
    }
  }

  /// Scrapes a LeekDuck event page to extract spawn pokemon.
  /// Parses <li> elements containing pokemon icon images.
  Future<void> _scrapeEventSpawns(
    String url,
    void Function({
      required String name,
      required String imageUrl,
      required bool canBeShiny,
    }) check,
  ) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) return;

      final html = resp.body;

      // Match <li> blocks containing pokemon icons
      // Pattern: <li>...<img src="...pokemon_icon...">...[optional shiny-icon]...PokemonName...</li>
      final liPattern = RegExp(
        r'<li[^>]*>(.*?)</li>',
        dotAll: true,
      );

      final pokemonImgPattern = RegExp(
        r'<img[^>]+src="(https://cdn\.leekduck\.com/assets/img/pokemon_icons/[^"]+)"',
      );

      final shinyPattern = RegExp(r'shiny-icon\.png');

      // Extract pokemon name from text after the img tags
      final namePattern = RegExp(r'>\s*([A-Z][a-zA-Zé\-\.\s]+?)\s*<');

      for (final liMatch in liPattern.allMatches(html)) {
        final liContent = liMatch.group(1) ?? '';

        final imgMatch = pokemonImgPattern.firstMatch(liContent);
        if (imgMatch == null) continue;

        final imageUrl = imgMatch.group(1)!;
        final canBeShiny = shinyPattern.hasMatch(liContent);

        // Try to extract the pokemon name
        String name = '';
        final nameMatch = namePattern.allMatches(liContent).lastOrNull;
        if (nameMatch != null) {
          name = nameMatch.group(1)?.trim() ?? '';
        }

        if (name.isEmpty) {
          // Fallback: extract from image URL
          final idMatch = RegExp(r'pm(\d+)').firstMatch(imageUrl);
          if (idMatch == null) {
            final iconMatch =
                RegExp(r'pokemon_icon_(\d+)').firstMatch(imageUrl);
            if (iconMatch != null) {
              name = '#${int.parse(iconMatch.group(1)!)}';
            }
          }
        }

        check(
          name: name,
          imageUrl: imageUrl,
          canBeShiny: canBeShiny,
        );
      }
    } catch (_) {}
  }

  /// Extracts the Pokémon ID from a LeekDuck image URL.
  /// Supports formats:
  /// - .../pm412.fBURMY_PLANT.icon.png or .../pm1.icon.png
  /// - .../pokemon_icon_025_00.png
  static int? _extractPokemonId(String url) {
    // Try pm{id} format first
    final pmMatch = RegExp(r'pm(\d+)').firstMatch(url);
    if (pmMatch != null) return int.tryParse(pmMatch.group(1)!);

    // Try pokemon_icon_{id} format
    final iconMatch = RegExp(r'pokemon_icon_(\d+)').firstMatch(url);
    if (iconMatch != null) return int.tryParse(iconMatch.group(1)!);

    return null;
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
