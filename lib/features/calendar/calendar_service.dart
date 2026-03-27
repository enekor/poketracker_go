// lib/features/calendar/calendar_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:poketracker_go/core/constants/api_constants.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class CalendarService extends GetxController {
  final events = <PogoEvent>[].obs;
  final raids = <RaidPokemon>[].obs;
  final eggs = <EggPokemon>[].obs;
  final research = <ResearchTask>[].obs;
  final rockets = <RocketMember>[].obs;

  final isLoading = true.obs;
  final selectedTab = 0.obs;

  /// Set of event heading types the user has chosen to hide.
  final hiddenEventTypes = <String>{}.obs;

  final _hive = Get.find<HiveService>();

  /// All distinct event heading values from the loaded data.
  List<String> get availableEventTypes {
    final types = events.map((e) => e.heading).toSet().toList();
    types.sort();
    return types;
  }

  /// Events filtered by the user's hidden-type preferences.
  List<PogoEvent> get filteredEvents {
    if (hiddenEventTypes.isEmpty) return events;
    return events.where((e) => !hiddenEventTypes.contains(e.heading)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFilters();
    loadAll();
  }

  void _loadFilters() {
    final saved = _hive.calendarFiltersBox.get('hiddenEventTypes');
    if (saved is List) {
      hiddenEventTypes.value = saved.cast<String>().toSet();
    }
  }

  Future<void> _saveFilters() async {
    await _hive.calendarFiltersBox
        .put('hiddenEventTypes', hiddenEventTypes.toList());
  }

  void toggleEventType(String heading) {
    if (hiddenEventTypes.contains(heading)) {
      hiddenEventTypes.remove(heading);
    } else {
      hiddenEventTypes.add(heading);
    }
    _saveFilters();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _loadEvents(),
      _loadRaids(),
      _loadEggs(),
      _loadResearch(),
      _loadRockets(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadEvents() async {
    try {
      final resp = await http.get(Uri.parse(ApiConstants.eventsUrl));
      if (resp.statusCode != 200) return;
      final list = json.decode(resp.body) as List;
      events.value = list.map((e) => PogoEvent.fromJson(e)).toList();
    } catch (_) {}
  }

  Future<void> _loadRaids() async {
    try {
      final resp = await http.get(Uri.parse(ApiConstants.raidsUrl));
      if (resp.statusCode != 200) return;
      final list = json.decode(resp.body) as List;
      raids.value = list.map((e) => RaidPokemon.fromJson(e)).toList();
    } catch (_) {}
  }

  Future<void> _loadEggs() async {
    try {
      final resp = await http.get(Uri.parse(ApiConstants.eggsUrl));
      if (resp.statusCode != 200) return;
      final list = json.decode(resp.body) as List;
      eggs.value = list.map((e) => EggPokemon.fromJson(e)).toList();
    } catch (_) {}
  }

  Future<void> _loadResearch() async {
    try {
      final resp = await http.get(Uri.parse(ApiConstants.researchUrl));
      if (resp.statusCode != 200) return;
      final list = json.decode(resp.body) as List;
      research.value = list.map((e) => ResearchTask.fromJson(e)).toList();
    } catch (_) {}
  }

  Future<void> _loadRockets() async {
    try {
      final resp = await http.get(Uri.parse(ApiConstants.rocketUrl));
      if (resp.statusCode != 200) return;
      final list = json.decode(resp.body) as List;
      rockets.value = list.map((e) => RocketMember.fromJson(e)).toList();
    } catch (_) {}
  }
}

// ─── Models ───────────────────────────────────────────────

class PogoEvent {
  final String eventId;
  final String name;
  final String eventType;
  final String heading;
  final String link;
  final String image;
  final DateTime? start;
  final DateTime? end;
  final bool hasSpawns;
  final List<EventSpawn> eventSpawns;

  PogoEvent({
    required this.eventId,
    required this.name,
    required this.eventType,
    required this.heading,
    required this.link,
    required this.image,
    this.start,
    this.end,
    this.hasSpawns = false,
    this.eventSpawns = const [],
  });

  factory PogoEvent.fromJson(Map<String, dynamic> json) {
    final extraData = json['extraData'] as Map<String, dynamic>? ?? {};
    final generic = extraData['generic'] as Map<String, dynamic>? ?? {};
    final hasSpawns = generic['hasSpawns'] == true;

    final spawns = <EventSpawn>[];

    // Community Day spawns
    final cd = extraData['communityday'] as Map<String, dynamic>?;
    if (cd != null) {
      final cdShinies = (cd['shinies'] as List? ?? [])
          .map((s) => (s['name'] as String?) ?? '')
          .toSet();
      for (final s in (cd['spawns'] as List? ?? [])) {
        spawns.add(EventSpawn(
          name: s['name'] ?? '',
          image: s['image'] ?? '',
          canBeShiny: cdShinies.contains(s['name'] ?? ''),
        ));
      }
    }

    // Raid battle bosses
    final rb = extraData['raidbattles'] as Map<String, dynamic>?;
    if (rb != null) {
      for (final b in (rb['bosses'] as List? ?? [])) {
        spawns.add(EventSpawn(
          name: b['name'] ?? '',
          image: b['image'] ?? '',
          canBeShiny: b['canBeShiny'] ?? false,
        ));
      }
    }

    return PogoEvent(
      eventId: json['eventID'] ?? '',
      name: json['name'] ?? '',
      eventType: json['eventType'] ?? '',
      heading: json['heading'] ?? '',
      link: json['link'] ?? '',
      image: json['image'] ?? '',
      start: json['start'] != null ? DateTime.tryParse(json['start']) : null,
      end: json['end'] != null ? DateTime.tryParse(json['end']) : null,
      hasSpawns: hasSpawns,
      eventSpawns: spawns,
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return start != null && end != null && now.isAfter(start!) && now.isBefore(end!);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return start != null && now.isBefore(start!);
  }
}

class RaidPokemon {
  final String name;
  final String tier;
  final bool canBeShiny;
  final List<String> types;
  final int? cpMin;
  final int? cpMax;
  final int? cpBoostedMin;
  final int? cpBoostedMax;
  final String image;

  RaidPokemon({
    required this.name,
    required this.tier,
    required this.canBeShiny,
    required this.types,
    this.cpMin,
    this.cpMax,
    this.cpBoostedMin,
    this.cpBoostedMax,
    required this.image,
  });

  factory RaidPokemon.fromJson(Map<String, dynamic> json) {
    final cp = json['combatPower'] as Map<String, dynamic>?;
    final normal = cp?['normal'] as Map<String, dynamic>?;
    final boosted = cp?['boosted'] as Map<String, dynamic>?;
    final types = (json['types'] as List?)
            ?.map((t) => (t['name'] as String?) ?? '')
            .toList() ??
        [];

    return RaidPokemon(
      name: json['name'] ?? '',
      tier: json['tier'] ?? '',
      canBeShiny: json['canBeShiny'] ?? false,
      types: types,
      cpMin: normal?['min'] as int?,
      cpMax: normal?['max'] as int?,
      cpBoostedMin: boosted?['min'] as int?,
      cpBoostedMax: boosted?['max'] as int?,
      image: json['image'] ?? '',
    );
  }
}

class EggPokemon {
  final String name;
  final String eggType;
  final bool canBeShiny;
  final bool isAdventureSync;
  final bool isRegional;
  final int rarity;
  final String image;

  EggPokemon({
    required this.name,
    required this.eggType,
    required this.canBeShiny,
    required this.isAdventureSync,
    required this.isRegional,
    required this.rarity,
    required this.image,
  });

  factory EggPokemon.fromJson(Map<String, dynamic> json) {
    return EggPokemon(
      name: json['name'] ?? '',
      eggType: json['eggType'] ?? '',
      canBeShiny: json['canBeShiny'] ?? false,
      isAdventureSync: json['isAdventureSync'] ?? false,
      isRegional: json['isRegional'] ?? false,
      rarity: json['rarity'] ?? 1,
      image: json['image'] ?? '',
    );
  }
}

class ResearchTask {
  final String text;
  final List<ResearchReward> rewards;

  ResearchTask({required this.text, required this.rewards});

  factory ResearchTask.fromJson(Map<String, dynamic> json) {
    final rewards = (json['rewards'] as List?)
            ?.map((r) => ResearchReward.fromJson(r))
            .toList() ??
        [];
    return ResearchTask(text: json['text'] ?? '', rewards: rewards);
  }
}

class ResearchReward {
  final String name;
  final String image;
  final bool canBeShiny;

  ResearchReward({
    required this.name,
    required this.image,
    required this.canBeShiny,
  });

  factory ResearchReward.fromJson(Map<String, dynamic> json) {
    return ResearchReward(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      canBeShiny: json['canBeShiny'] ?? false,
    );
  }
}

class RocketMember {
  final String name;
  final String title;
  final String type;
  final List<RocketPokemon> firstPokemon;
  final List<RocketPokemon> secondPokemon;
  final List<RocketPokemon> thirdPokemon;

  RocketMember({
    required this.name,
    required this.title,
    required this.type,
    required this.firstPokemon,
    required this.secondPokemon,
    required this.thirdPokemon,
  });

  factory RocketMember.fromJson(Map<String, dynamic> json) {
    return RocketMember(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      firstPokemon: _parsePokemonSlot(json['firstPokemon']),
      secondPokemon: _parsePokemonSlot(json['secondPokemon']),
      thirdPokemon: _parsePokemonSlot(json['thirdPokemon']),
    );
  }

  static List<RocketPokemon> _parsePokemonSlot(dynamic slot) {
    if (slot is! List) return [];
    return slot.map((p) => RocketPokemon.fromJson(p)).toList();
  }
}

class RocketPokemon {
  final String name;
  final String image;
  final bool isEncounter;
  final bool canBeShiny;

  RocketPokemon({
    required this.name,
    required this.image,
    required this.isEncounter,
    required this.canBeShiny,
  });

  factory RocketPokemon.fromJson(Map<String, dynamic> json) {
    return RocketPokemon(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isEncounter: json['isEncounter'] ?? false,
      canBeShiny: json['canBeShiny'] ?? false,
    );
  }
}

class EventSpawn {
  final String name;
  final String image;
  final bool canBeShiny;

  const EventSpawn({
    required this.name,
    required this.image,
    required this.canBeShiny,
  });
}
