// lib/features/pokedex/pokedex_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/features/pokedex/pokedex_base_service.dart';

/// Read-only Pokédex: browse collection, view detail on tap.
class PokedexService extends PokedexBaseService {
  final RxMap<int, UserPokemonModel> userPokemon =
      <int, UserPokemonModel>{}.obs;

  final ScrollController normalScrollController = ScrollController();
  final ScrollController shinyScrollController = ScrollController();
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    loadData();
    _syncScrollControllers();
  }

  @override
  void onClose() {
    normalScrollController.dispose();
    shinyScrollController.dispose();
    pageController.dispose();
    super.onClose();
  }

  @override
  void onDataLoaded() {
    userPokemon.assignAll(hiveService.getAllUserPokemon());
  }

  @override
  bool isOwned(int pokemonId) {
    return currentPage.value == 1
        ? hasShiny(pokemonId)
        : hasNormal(pokemonId);
  }

  bool hasNormal(int pokemonId) =>
      userPokemon[pokemonId]?.hasNormal ?? false;

  bool hasShiny(int pokemonId) =>
      userPokemon[pokemonId]?.hasShiny ?? false;

  void onPageChanged(int page) => currentPage.value = page;

  void refreshUserData() {
    userPokemon.assignAll(hiveService.getAllUserPokemon());
  }

  void _syncScrollControllers() {
    normalScrollController.addListener(() {
      if (currentPage.value == 0 && shinyScrollController.hasClients) {
        shinyScrollController.jumpTo(normalScrollController.offset);
      }
    });
    shinyScrollController.addListener(() {
      if (currentPage.value == 1 && normalScrollController.hasClients) {
        normalScrollController.jumpTo(shinyScrollController.offset);
      }
    });
  }
}
