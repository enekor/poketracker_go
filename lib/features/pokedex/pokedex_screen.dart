// lib/features/pokedex/pokedex_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/routes/app_routes.dart';
import 'package:poketracker_go/core/widgets/skeleton.dart';
import 'package:poketracker_go/features/pokedex/pokedex_base_service.dart';
import 'package:poketracker_go/features/pokedex/pokedex_service.dart';
import 'package:poketracker_go/features/pokedex/pokedex_selector_service.dart';
import 'package:poketracker_go/features/pokedex/pokedex_widgets.dart';

enum PokedexMode { view, select }

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = Get.arguments as PokedexMode? ?? PokedexMode.view;
    final isSelectMode = mode == PokedexMode.select;

    // Instantiate the right service
    final PokedexBaseService service = isSelectMode
        ? Get.put(PokedexSelectorService())
        : Get.put(PokedexService());

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectMode ? 'Registrar Pokémon' : 'Pokédex'),
        centerTitle: true,
      ),
      bottomNavigationBar:
          isSelectMode ? _buildSaveBar(context, service as PokedexSelectorService) : null,
      body: Obx(() {
        return Column(
          children: [
            // Variant toggle tabs
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: NormalShinyIndicator(
                currentPage: service.currentPage.value,
                onTap: isSelectMode
                    ? (service as PokedexSelectorService).toggleMode
                    : (page) {
                        final svc = service as PokedexService;
                        svc.pageController.animateToPage(
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
            OwnershipFilterBar(
              selectedFilter: service.ownershipFilter.value,
              onSelected: service.selectOwnershipFilter,
            ),
            // Search bar
            PokemonSearchBar(onChanged: service.onSearchChanged),
            // Grid (or skeleton while loading)
            Expanded(
              child: service.isLoading.value
                  ? const PokedexGridSkeleton()
                  : isSelectMode
                      ? _buildSelectGrid(service as PokedexSelectorService)
                      : _buildViewBody(service as PokedexService),
            ),
          ],
        );
      }),
    );
  }

  // ─── View mode ───

  Widget _buildViewBody(PokedexService service) {
    return PageView(
      controller: service.pageController,
      onPageChanged: service.onPageChanged,
      children: List.generate(PokedexService.pageCount, (page) =>
        _buildViewGrid(service, page: page),
      ),
    );
  }

  Widget _buildViewGrid(PokedexService service, {required int page}) {
    final groups = service.pokemonByGeneration;
    final isShiny = page == 1 || page == 4 || page == 5;

    return CustomScrollView(
      controller: service.scrollControllers[page],
      slivers: _buildGridSlivers(
        groups: groups,
        tileBuilder: (pokemon) => PokemonGridTile(
          pokemon: pokemon,
          isOwned: service.hasVariant(pokemon.id, page),
          isShiny: isShiny,
          variant: page,
          onTap: () => Get.toNamed(AppRoutes.pokemonDetail, arguments: pokemon),
        ),
      ),
    );
  }

  // ─── Select mode ───

  Widget _buildSelectGrid(PokedexSelectorService service) {
    final groups = service.pokemonByGeneration;
    final page = service.currentPage.value;
    final isShiny = page == 1 || page == 4 || page == 5;

    return CustomScrollView(
      slivers: _buildGridSlivers(
        groups: groups,
        tileBuilder: (pokemon) => Obx(() => SelectablePokemonTile(
              pokemon: pokemon,
              isSelected: service.isSelected(pokemon.id),
              isShiny: isShiny,
              onTap: () => service.togglePokemon(pokemon.id),
            )),
      ),
    );
  }

  // ─── Shared grid builder ───

  List<Widget> _buildGridSlivers({
    required List<MapEntry<int, List<dynamic>>> groups,
    required Widget Function(dynamic pokemon) tileBuilder,
  }) {
    return [
      for (final entry in groups) ...[
        SliverToBoxAdapter(
          child: GenerationHeader(
            generation: entry.key,
            onSelectAll: Get.find<PokedexBaseService>() is PokedexSelectorService
                ? () => (Get.find<PokedexBaseService>() as PokedexSelectorService)
                    .selectAllInGeneration(entry.key)
                : null,
          ),
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => tileBuilder(entry.value[index]),
            childCount: entry.value.length,
          ),
        ),
      ],
    ];
  }

  // ─── Save bar ───

  Widget _buildSaveBar(BuildContext context, PokedexSelectorService service) {
    return Obx(() {
      final hasChanges = service.hasChanges;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: hasChanges ? 64 : 0,
        child: hasChanges
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.08),
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
    });
  }
}
