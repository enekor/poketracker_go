// lib/features/pokedex/pokedex_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/routes/app_routes.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/features/pokedex/pokedex_service.dart';
import 'package:poketracker_go/features/pokedex/pokedex_widgets.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(PokedexService());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Normal / Shiny indicator
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: NormalShinyIndicator(
                currentPage: service.currentPage.value,
                onTap: (page) {
                  service.pageController.animateToPage(
                    page,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            // Generation chips
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GenerationChipBar(
                selectedGeneration: service.selectedGeneration.value,
                onSelected: service.selectGeneration,
              ),
            ),
            // Ownership filter
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: OwnershipFilterBar(
                selectedFilter: service.ownershipFilter.value,
                onSelected: service.selectOwnershipFilter,
              ),
            ),
            // Search bar
            PokemonSearchBar(onChanged: service.onSearchChanged),
            // Grid PageView
            Expanded(
              child: PageView(
                controller: service.pageController,
                onPageChanged: service.onPageChanged,
                children: [
                  _buildGrid(service, isShiny: false),
                  _buildGrid(service, isShiny: true),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGrid(PokedexService service, {required bool isShiny}) {
    final groups = service.pokemonByGeneration;
    final scrollController =
        isShiny ? service.shinyScrollController : service.normalScrollController;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        for (final entry in groups) ...[
          SliverToBoxAdapter(
            child: GenerationHeader(generation: entry.key),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final pokemon = entry.value[index];
                final isOwned = isShiny
                    ? service.hasShiny(pokemon.id)
                    : service.hasNormal(pokemon.id);

                return PokemonGridTile(
                  pokemon: pokemon,
                  isOwned: isOwned,
                  isShiny: isShiny,
                  onTap: () => Get.toNamed(
                    AppRoutes.pokemonDetail,
                    arguments: pokemon,
                  ),
                );
              },
              childCount: entry.value.length,
            ),
          ),
        ],
      ],
    );
  }
}
