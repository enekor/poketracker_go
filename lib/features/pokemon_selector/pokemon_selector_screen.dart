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
      bottomNavigationBar: Obx(() {
        final hasChanges = service.hasChanges;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: hasChanges ? 64 : 0,
          child: hasChanges
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: service.saveSelection,
                        icon: const Icon(Icons.save_rounded, size: 20),
                        label: const Text('Guardar cambios'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      }),
      body: Obx(() {
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = service.pokemonByGeneration;
        // Read mode here so this Obx reacts to mode changes
        final isShiny = service.mode.value == 1;

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
                          return Obx(() => SelectablePokemonTile(
                            pokemon: pokemon,
                            isSelected: service.isSelected(pokemon.id),
                            isShiny: isShiny,
                            onTap: () => service.togglePokemon(pokemon.id),
                          ));
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
