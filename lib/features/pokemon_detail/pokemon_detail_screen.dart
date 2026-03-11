// lib/features/pokemon_detail/pokemon_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_service.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_widgets.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(PokemonDetailService());
    final showShiny = false.obs;

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
                  final canToggleToShiny = service.hasShiny.value;
                  final canToggleToNormal = service.hasNormal.value;

                  return PokemonSpriteViewer(
                    normalUrl: pokemon.spriteUrl,
                    shinyUrl: pokemon.spriteShinyUrl,
                    showShiny: showShiny.value,
                    onToggle: () {
                      if (showShiny.value && canToggleToNormal) {
                        showShiny.value = false;
                      } else if (!showShiny.value && canToggleToShiny) {
                        showShiny.value = true;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Obx(
                () {
                  final canSwitch = showShiny.value
                      ? service.hasNormal.value
                      : service.hasShiny.value;
                  final label = showShiny.value ? 'Shiny' : 'Normal';
                  final hint = canSwitch
                      ? '$label (toca para cambiar)'
                      : '$label';

                  return Text(
                    hint,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
              // Ownership badges (tappable to switch sprite)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OwnershipBadge(
                    label: 'Normal',
                    owned: service.hasNormal.value,
                    active: !showShiny.value,
                    onTap: service.hasNormal.value
                        ? () => showShiny.value = false
                        : null,
                  ),
                  const SizedBox(width: 24),
                  OwnershipBadge(
                    label: 'Shiny',
                    owned: service.hasShiny.value,
                    active: showShiny.value,
                    onTap: service.hasShiny.value
                        ? () => showShiny.value = true
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
