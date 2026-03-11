// lib/features/pokemon_selector/pokemon_selector_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/features/pokedex/pokedex_widgets.dart';
import 'package:poketracker_go/features/pokemon_selector/pokemon_selector_service.dart';
import 'package:poketracker_go/features/pokemon_selector/pokemon_selector_widgets.dart';

class PokemonSelectorScreen extends StatelessWidget {
  const PokemonSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(PokemonSelectorService());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pokémon'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: service.saveSelection,
        icon: const Icon(Icons.save),
        label: const Text('Guardar'),
      ),
      body: Obx(() {
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = service.pokemonByGeneration;

        return Column(
          children: [
            // Normal / Shiny toggle
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SelectorModeToggle(
                currentMode: service.mode.value,
                onChanged: service.toggleMode,
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
            // Search bar
            PokemonSearchBar(onChanged: service.onSearchChanged),
            // Grid
            Expanded(
              child: CustomScrollView(
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
                          return SelectablePokemonTile(
                            pokemon: pokemon,
                            isSelected: service.isSelected(pokemon.id),
                            isShiny: service.mode.value == 1,
                            onTap: () => service.togglePokemon(pokemon.id),
                          );
                        },
                        childCount: entry.value.length,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
