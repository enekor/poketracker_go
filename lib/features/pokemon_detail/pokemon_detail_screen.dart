// lib/features/pokemon_detail/pokemon_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_service.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_widgets.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(PokemonDetailService());
    final showShiny = false.obs;
    final showFemale = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(service.capitalizedName())),
        centerTitle: true,
      ),
      body: Obx(() {
        if (service.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final pokemon = service.pokemon.value;
        if (pokemon == null) {
          return const Center(child: Text('Pokémon no encontrado'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Sprite viewer
              Obx(
                () {
                  final spriteCtrl = Get.find<SpriteStyleController>();
                  final isPixelArt = spriteCtrl.usePixelArt.value;
                  String spriteUrl;

                  if (isPixelArt && showFemale.value) {
                    // Female pixel art sprites (from API)
                    if (showShiny.value) {
                      spriteUrl = pokemon.spriteShinyFemaleUrl ?? pokemon.spriteShinyUrl;
                    } else {
                      spriteUrl = pokemon.spriteFemaleUrl ?? pokemon.spriteUrl;
                    }
                  } else {
                    // Standard or 3D sprites (no female variant in Home)
                    spriteUrl = showShiny.value
                        ? spriteCtrl.spriteShinyUrl(pokemon.id)
                        : spriteCtrl.spriteUrl(pokemon.id);
                  }

                  return PokemonSpriteViewer(
                    spriteUrl: spriteUrl,
                    usePixelArt: isPixelArt,
                  );
                },
              ),
              const SizedBox(height: 12),
              // Shiny toggle + Gender toggle
              Obx(
                () {
                  final theme = Theme.of(context);
                  final spriteCtrl = Get.find<SpriteStyleController>();
                  final showGender = spriteCtrl.usePixelArt.value &&
                      service.hasFemaleSprite.value;

                  // Reset female when switching to 3D
                  if (!spriteCtrl.usePixelArt.value && showFemale.value) {
                    showFemale.value = false;
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Normal / Shiny toggle
                      _buildToggleChip(
                        context,
                        label: 'Normal',
                        isActive: !showShiny.value,
                        onTap: () => showShiny.value = false,
                      ),
                      const SizedBox(width: 8),
                      _buildToggleChip(
                        context,
                        label: 'Shiny',
                        icon: Icons.auto_awesome,
                        isActive: showShiny.value,
                        onTap: () => showShiny.value = true,
                      ),
                      if (showGender) ...[
                        const SizedBox(width: 16),
                        Container(
                          width: 1,
                          height: 28,
                          color: theme.colorScheme.onSurface.withOpacity(0.15),
                        ),
                        const SizedBox(width: 16),
                        _buildToggleChip(
                          context,
                          label: '♂',
                          isActive: !showFemale.value,
                          onTap: () => showFemale.value = false,
                        ),
                        const SizedBox(width: 8),
                        _buildToggleChip(
                          context,
                          label: '♀',
                          isActive: showFemale.value,
                          onTap: () => showFemale.value = true,
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Name and number
              Text(
                '${pokemon.formattedId} — ${service.capitalizedName()}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Types
              if (pokemon.types.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: pokemon.types.map((t) => TypeChip(type: t)).toList(),
                ),
              const SizedBox(height: 24),
              // Ownership badges
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OwnershipBadge(
                    label: 'Normal',
                    owned: service.hasNormal.value,
                  ),
                  const SizedBox(width: 24),
                  OwnershipBadge(
                    label: 'Shiny',
                    owned: service.hasShiny.value,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildToggleChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
