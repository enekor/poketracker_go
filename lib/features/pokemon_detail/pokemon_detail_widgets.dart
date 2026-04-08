// lib/features/pokemon_detail/pokemon_detail_widgets.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
import 'package:poketracker_go/core/services/api_service.dart';
import 'package:get/get.dart';

/// Large sprite display with optional variant aura.
class PokemonSpriteViewer extends StatelessWidget {
  final String spriteUrl;
  final bool usePixelArt;
  /// 0=Normal,1=Shiny,2=Shadow,3=Purified,4=ShadowShiny,5=PurifiedShiny
  final int variant;

  const PokemonSpriteViewer({
    super.key,
    required this.spriteUrl,
    this.usePixelArt = true,
    this.variant = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spriteSize = screenWidth * 0.65;

    final isShadow = variant == 2 || variant == 4;
    final isPurified = variant == 3 || variant == 5;

    final auraColor = isShadow
        ? const Color(0xFF6A1B9A)
        : isPurified
            ? const Color(0xFF64B5F6)
            : null;

    return SizedBox(
      height: spriteSize,
      width: spriteSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (auraColor != null) ...[
            // Outer soft glow
            Positioned(
              left: -20,
              right: -20,
              top: -20,
              bottom: -20,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: auraColor.withOpacity(0.5),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            // Inner radial gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      auraColor.withOpacity(0.50),
                      auraColor.withOpacity(0.25),
                      auraColor.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
          CachedNetworkImage(
            imageUrl: spriteUrl,
            fit: BoxFit.contain,
            filterQuality: usePixelArt ? FilterQuality.none : FilterQuality.low,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.error_outline, size: 64),
          ),
        ],
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

/// Ownership toggle — supports Normal, Shiny, Shadow, Purified, Shadow Shiny, Purified Shiny.
class OwnershipToggle extends StatelessWidget {
  final Map<int, bool> variants; // page index -> has variant
  final int activeVariant; // currently displayed variant
  final ValueChanged<int> onVariantTap;

  const OwnershipToggle({
    super.key,
    required this.variants,
    required this.activeVariant,
    required this.onVariantTap,
  });

  static const _variantInfo = [
    (label: 'Normal', icon: Icons.catching_pokemon),
    (label: 'Shiny', icon: Icons.auto_awesome),
    (label: 'Oscuro', icon: Icons.cloud_rounded),
    (label: 'Purif.', icon: Icons.favorite_rounded),
    (label: 'Osc. ✨', icon: Icons.cloud_rounded),
    (label: 'Pur. ✨', icon: Icons.favorite_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_variantInfo.length, (i) {
        final info = _variantInfo[i];
        final isOwned = variants[i] ?? false;
        final isActive = activeVariant == i;
        return _buildChip(
          context,
          label: info.label,
          icon: info.icon,
          isActive: isActive,
          isLocked: !isOwned,
          onTap: isOwned ? () => onVariantTap(i) : null,
        );
      }),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked) ...[
              Icon(Icons.lock_outline, size: 14, color: fgColor),
              const SizedBox(width: 4),
            ] else ...[
              Icon(icon, size: 14, color: fgColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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

/// Displays the evolution chain as a horizontal row of stages with arrows.
class EvolutionChainWidget extends StatelessWidget {
  final List<List<EvolutionEntry>> stages;
  final int currentPokemonId;
  final void Function(EvolutionEntry entry) onTap;

  const EvolutionChainWidget({
    super.key,
    required this.stages,
    required this.currentPokemonId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if only one stage with one Pokémon (no evolution)
    if (stages.length <= 1 && (stages.firstOrNull?.length ?? 0) <= 1) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cadena evolutiva',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < stages.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                // If a stage has multiple Pokémon (e.g. Eevee evolutions),
                // stack them vertically
                if (stages[i].length == 1)
                  _EvolutionTile(
                    entry: stages[i].first,
                    isCurrent: stages[i].first.id == currentPokemonId,
                    onTap: () => onTap(stages[i].first),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: stages[i]
                        .map((entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: _EvolutionTile(
                                entry: entry,
                                isCurrent: entry.id == currentPokemonId,
                                onTap: () => onTap(entry),
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EvolutionTile extends StatelessWidget {
  final EvolutionEntry entry;
  final bool isCurrent;
  final VoidCallback onTap;

  const _EvolutionTile({
    required this.entry,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spriteCtrl = Get.find<SpriteStyleController>();
    final spriteUrl = spriteCtrl.spriteUrl(entry.id);
    final isPixelArt = spriteCtrl.usePixelArt.value;

    return GestureDetector(
      onTap: isCurrent ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: isCurrent
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CachedNetworkImage(
                imageUrl: spriteUrl,
                fit: BoxFit.contain,
                filterQuality:
                    isPixelArt ? FilterQuality.none : FilterQuality.low,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.catching_pokemon, size: 32),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.name[0].toUpperCase() + entry.name.substring(1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
