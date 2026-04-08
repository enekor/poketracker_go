// lib/features/pokedex/pokedex_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/theme/app_colors.dart';
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
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
    final spriteCtrl = Get.find<SpriteStyleController>();
    final spriteUrl = widget.isShiny
        ? spriteCtrl.spriteShinyUrl(widget.pokemon.id)
        : spriteCtrl.spriteUrl(widget.pokemon.id);

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
  final VoidCallback? onSelectAll;

  const GenerationHeader({
    super.key,
    required this.generation,
    this.onSelectAll,
  });

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            genData['name'] as String,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : theme.colorScheme.primary.withOpacity(0.8),
            ),
          ),
          if (onSelectAll != null)
            TextButton.icon(
              onPressed: onSelectAll,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text(
                'Seleccionar Todos',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: theme.brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.9)
                    : theme.colorScheme.primary,
              ),
            ),
        ],
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

/// Ownership filter chip bar (All / Owned / Not owned).
class OwnershipFilterBar extends StatelessWidget {
  final int selectedFilter;
  final ValueChanged<int> onSelected;

  const OwnershipFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = ['Todos', 'Capturados', 'Sin capturar'];
    final icons = [Icons.apps_rounded, Icons.catching_pokemon, Icons.radio_button_unchecked];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = selectedFilter == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ChoiceChip(
              avatar: Icon(
                icons[index],
                size: 16,
                color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              label: Text(labels[index]),
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

/// Variant tab indicator (Normal, Shiny, Shadow, Purified, Shadow Shiny, Purified Shiny).
class NormalShinyIndicator extends StatelessWidget {
  final int currentPage;
  final ValueChanged<int> onTap;

  const NormalShinyIndicator({
    super.key,
    required this.currentPage,
    required this.onTap,
  });

  static const _tabs = [
    (icon: Icons.catching_pokemon, secondIcon: null, color: Color(0xFFE53935)),
    (icon: Icons.auto_awesome, secondIcon: null, color: Color(0xFFFFC107)),
    (icon: Icons.cloud_rounded, secondIcon: null, color: Color(0xFF6A1B9A)),
    (icon: Icons.favorite_rounded, secondIcon: null, color: Color(0xFF00897B)),
    (icon: Icons.cloud_rounded, secondIcon: Icons.auto_awesome, color: Color(0xFF6A1B9A)),
    (icon: Icons.favorite_rounded, secondIcon: Icons.auto_awesome, color: Color(0xFF00897B)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = currentPage == index;
          final tab = _tabs[index];
          final activeColor = tab.color;
          final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.35);

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.12)
                    : theme.colorScheme.onSurface.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: isActive
                    ? Border.all(color: activeColor.withOpacity(0.5), width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 20,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  if (tab.secondIcon != null) ...[
                    const SizedBox(width: 2),
                    Icon(
                      tab.secondIcon!,
                      size: 14,
                      color: isActive ? const Color(0xFFFFC107) : inactiveColor,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A selectable Pokémon tile for the selector grid.
class SelectablePokemonTile extends StatelessWidget {
  final PokemonModel pokemon;
  final bool isSelected;
  final bool isShiny;
  final VoidCallback onTap;

  const SelectablePokemonTile({
    super.key,
    required this.pokemon,
    required this.isSelected,
    required this.isShiny,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spriteCtrl = Get.find<SpriteStyleController>();
    final spriteUrl = isShiny
        ? spriteCtrl.spriteShinyUrl(pokemon.id)
        : spriteCtrl.spriteUrl(pokemon.id);
    final selectedColor = theme.brightness == Brightness.dark
        ? AppColors.selectedBorderDark
        : AppColors.selectedBorderLight;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected
              ? BorderSide(color: selectedColor, width: 2.5)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CachedNetworkImage(
                      imageUrl: spriteUrl,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.error_outline),
                      fit: BoxFit.contain,
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
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child:
                    Icon(Icons.check_circle, color: selectedColor, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
