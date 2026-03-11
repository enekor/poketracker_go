// lib/features/pokemon_selector/pokemon_selector_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poketracker_go/app/theme/app_colors.dart';
import 'package:poketracker_go/core/models/pokemon_model.dart';

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
    final spriteUrl = isShiny ? pokemon.spriteShinyUrl : pokemon.spriteUrl;
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
                      errorWidget: (_, __, ___) => const Icon(Icons.error_outline),
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
                child: Icon(Icons.check_circle, color: selectedColor, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

/// Toggle for Normal/Shiny mode in the selector.
class SelectorModeToggle extends StatelessWidget {
  final int currentMode;
  final ValueChanged<int> onChanged;

  const SelectorModeToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Normal'),
          selected: currentMode == 0,
          selectedColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: currentMode == 0 ? Colors.white : theme.colorScheme.onSurface,
          ),
          onSelected: (_) => onChanged(0),
        ),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('Shiny'),
          selected: currentMode == 1,
          selectedColor: theme.colorScheme.primary,
          labelStyle: TextStyle(
            color: currentMode == 1 ? Colors.white : theme.colorScheme.onSurface,
          ),
          onSelected: (_) => onChanged(1),
        ),
      ],
    );
  }
}
