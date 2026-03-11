// lib/features/pokedex/pokedex_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poketracker_go/app/theme/app_colors.dart';
import 'package:poketracker_go/core/constants/pokemon_generations.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';
import 'package:poketracker_go/core/utils/image_utils.dart';

/// A single Pokémon tile in the grid.
class PokemonGridTile extends StatefulWidget {
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
  State<PokemonGridTile> createState() => _PokemonGridTileState();
}

class _PokemonGridTileState extends State<PokemonGridTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spriteUrl = widget.isShiny ? widget.pokemon.spriteShinyUrl : widget.pokemon.spriteUrl;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.brightness == Brightness.dark
                    ? [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.8),
                      ]
                    : [
                        theme.colorScheme.surface,
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Subtle background ID text
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Text(
                          widget.pokemon.formattedId,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ColorFiltered(
                          colorFilter: widget.isOwned
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                              : ImageUtils.greyscaleFilter(context),
                          child: CachedNetworkImage(
                            imageUrl: spriteUrl,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => const Icon(Icons.error_outline, size: 20),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: theme.colorScheme.onSurface.withOpacity(0.03),
                  child: Text(
                    widget.pokemon.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        genData['name'] as String,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : theme.colorScheme.primary.withOpacity(0.8),
        ),
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

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: romanNumerals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = selectedGeneration == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ChoiceChip(
              label: Text(romanNumerals[index]),
              selected: isActive,
              onSelected: (_) => onSelected(index),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surface
                  : Colors.white,
              elevation: isActive ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o número...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary.withOpacity(0.5)),
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? theme.colorScheme.surface
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab(context, 'NORMAL', 0, theme),
          const SizedBox(width: 48),
          _buildTab(context, 'SHINY', 1, theme),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int index, ThemeData theme) {
    final isActive = currentPage == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.2,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: 32,
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
