// lib/features/pokedex/pokedex_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poketracker_go/app/theme/app_colors.dart';
import 'package:poketracker_go/core/constants/pokemon_generations.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/core/utils/image_utils.dart';

/// A single Pokémon tile in the grid.
class PokemonGridTile extends StatelessWidget {
  final PokemonModel pokemon;
  final bool isOwned;
  final bool isShiny;
  final VoidCallback? onTap;

  const PokemonGridTile({
    super.key,
    required this.pokemon,
    required this.isOwned,
    this.isShiny = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spriteUrl = isShiny ? pokemon.spriteShinyUrl : pokemon.spriteUrl;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ColorFiltered(
                  colorFilter: isOwned
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                      : ImageUtils.greyscaleFilter(context),
                  child: CachedNetworkImage(
                    imageUrl: spriteUrl,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const Icon(Icons.error_outline),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                pokemon.formattedId,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky header for a generation group.
class GenerationHeader extends StatelessWidget {
  final int generation;

  const GenerationHeader({super.key, required this.generation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genData = pokemonGenerations[generation]!;
    final bgColor = theme.brightness == Brightness.dark
        ? AppColors.generationHeaderDark
        : AppColors.generationHeaderLight;

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        genData['name'] as String,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Horizontal chip bar for selecting generations.
class GenerationChipBar extends StatelessWidget {
  final int selectedGeneration;
  final ValueChanged<int> onSelected;

  const GenerationChipBar({
    super.key,
    required this.selectedGeneration,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final romanNumerals = ['Todas', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: romanNumerals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = selectedGeneration == index;
          return ChoiceChip(
            label: Text(romanNumerals[index]),
            selected: isActive,
            selectedColor: theme.colorScheme.primary,
            labelStyle: TextStyle(
              color: isActive ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 12,
            ),
            backgroundColor: theme.colorScheme.surface,
            onSelected: (_) => onSelected(index),
          );
        },
      ),
    );
  }
}

/// Search bar for filtering Pokémon.
class PokemonSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const PokemonSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o número...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }
}

/// Normal / Shiny tab indicator.
class NormalShinyIndicator extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onTap;

  const NormalShinyIndicator({
    super.key,
    required this.currentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab(context, 'Normal', 0, theme),
        const SizedBox(width: 24),
        _buildTab(context, 'Shiny', 1, theme),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String label, int index, ThemeData theme) {
    final isActive = currentPage == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
