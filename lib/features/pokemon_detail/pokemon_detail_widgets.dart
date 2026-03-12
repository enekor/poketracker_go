// lib/features/pokemon_detail/pokemon_detail_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Large sprite display.
class PokemonSpriteViewer extends StatelessWidget {
  final String spriteUrl;
  final bool usePixelArt;

  const PokemonSpriteViewer({
    super.key,
    required this.spriteUrl,
    this.usePixelArt = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spriteSize = screenWidth * 0.65;

    return SizedBox(
      height: spriteSize,
      width: spriteSize,
      child: CachedNetworkImage(
        imageUrl: spriteUrl,
        fit: BoxFit.contain,
        filterQuality: usePixelArt ? FilterQuality.none : FilterQuality.low,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Icon(Icons.error_outline, size: 64),
      ),
    );
  }
}

/// Displays a type chip (Fire, Water, etc.).
class TypeChip extends StatelessWidget {
  final String type;

  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        type[0].toUpperCase() + type.substring(1),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _typeColor(type),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Color _typeColor(String type) {
    const map = {
      'normal': Color(0xFFA8A878),
      'fire': Color(0xFFF08030),
      'water': Color(0xFF6890F0),
      'electric': Color(0xFFF8D030),
      'grass': Color(0xFF78C850),
      'ice': Color(0xFF98D8D8),
      'fighting': Color(0xFFC03028),
      'poison': Color(0xFFA040A0),
      'ground': Color(0xFFE0C068),
      'flying': Color(0xFFA890F0),
      'psychic': Color(0xFFF85888),
      'bug': Color(0xFFA8B820),
      'rock': Color(0xFFB8A038),
      'ghost': Color(0xFF705898),
      'dragon': Color(0xFF7038F8),
      'dark': Color(0xFF705848),
      'steel': Color(0xFFB8B8D0),
      'fairy': Color(0xFFEE99AC),
    };
    return map[type] ?? const Color(0xFF68A090);
  }
}

/// Ownership indicator badge.
class OwnershipBadge extends StatelessWidget {
  final String label;
  final bool owned;

  const OwnershipBadge({
    super.key,
    required this.label,
    required this.owned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.onSurface.withOpacity(0.04),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            owned ? Icons.check_circle : Icons.cancel,
            color: owned ? Colors.green : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
