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
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) =>
            const Icon(Icons.error_outline, size: 64),
      ),
    );
  }
}

/// Tappable gender selector: shows ♂/♀ and toggles on tap.
class GenderSelector extends StatelessWidget {
  final bool isFemale;
  final VoidCallback onTap;

  const GenderSelector({
    super.key,
    required this.isFemale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _genderIcon('♂', !isFemale, Colors.blue, theme),
          const SizedBox(width: 12),
          _genderIcon('♀', isFemale, Colors.pink, theme),
        ],
      ),
    );
  }

  Widget _genderIcon(
      String symbol, bool isActive, Color activeColor, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withOpacity(0.15)
            : theme.colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: activeColor.withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isActive
              ? activeColor
              : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
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

/// Normal / Shiny toggle — only unlocked options are tappable.
class OwnershipToggle extends StatelessWidget {
  final bool hasNormal;
  final bool hasShiny;
  final bool showShiny;
  final VoidCallback? onNormal;
  final VoidCallback? onShiny;

  const OwnershipToggle({
    super.key,
    required this.hasNormal,
    required this.hasShiny,
    required this.showShiny,
    this.onNormal,
    this.onShiny,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(
          context,
          label: 'Normal',
          isActive: !showShiny,
          isLocked: !hasNormal,
          onTap: onNormal,
        ),
        const SizedBox(width: 12),
        _buildChip(
          context,
          label: 'Shiny',
          icon: Icons.auto_awesome,
          isActive: showShiny,
          isLocked: !hasShiny,
          onTap: onShiny,
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isActive,
    required bool isLocked,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final Color bgColor;
    final Color fgColor;

    if (isLocked) {
      bgColor = theme.colorScheme.onSurface.withOpacity(0.04);
      fgColor = theme.colorScheme.onSurface.withOpacity(0.25);
    } else if (isActive) {
      bgColor = theme.colorScheme.primary;
      fgColor = Colors.white;
    } else {
      bgColor = theme.colorScheme.onSurface.withOpacity(0.06);
      fgColor = theme.colorScheme.onSurface.withOpacity(0.6);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked) ...[
              Icon(Icons.lock_outline, size: 14, color: fgColor),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 14, color: fgColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
