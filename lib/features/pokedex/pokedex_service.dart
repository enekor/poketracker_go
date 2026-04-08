// lib/features/pokedex/pokedex_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/features/pokedex/pokedex_base_service.dart';

/// Read-only Pokédex: browse collection, view detail on tap.
class PokedexService extends PokedexBaseService {
  static const int pageCount = 6;

  final RxMap<int, UserPokemonModel> userPokemon =
      <int, UserPokemonModel>{}.obs;

  final PageController pageController = PageController();
  late final List<ScrollController> scrollControllers;

  double _savedOffset = 0;

  @override
  void onInit() {
    scrollControllers = List.generate(pageCount, (_) => ScrollController());
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    for (final c in scrollControllers) {
      c.dispose();
    }
    pageController.dispose();
    super.onClose();
  }

  @override
  void onDataLoaded() {
    userPokemon.assignAll(hiveService.getAllUserPokemon());
  }

  @override
  bool isOwned(int pokemonId) {
    return hasVariant(pokemonId, currentPage.value);
  }

  bool hasVariant(int pokemonId, int page) {
    final u = userPokemon[pokemonId];
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

  bool hasNormal(int pokemonId) => hasVariant(pokemonId, 0);
  bool hasShiny(int pokemonId) => hasVariant(pokemonId, 1);

  void onPageChanged(int page) {
    // Save current scroll offset
    final cur = scrollControllers[currentPage.value];
    if (cur.hasClients) _savedOffset = cur.offset;

    currentPage.value = page;

    // Restore offset on the new page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final next = scrollControllers[page];
      if (next.hasClients) {
        next.jumpTo(_savedOffset.clamp(0, next.position.maxScrollExtent));
      }
    });
  }

  void refreshUserData() {
    userPokemon.assignAll(hiveService.getAllUserPokemon());
  }
}
