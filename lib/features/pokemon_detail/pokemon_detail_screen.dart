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
              // Sprite viewer (tap to toggle normal/shiny)
              Obx(
                () => PokemonSpriteViewer(
                  normalUrl: pokemon.spriteUrl,
                  shinyUrl: pokemon.spriteShinyUrl,
                  showShiny: showShiny.value,
                  onToggle: () => showShiny.value = !showShiny.value,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  showShiny.value ? 'Shiny (toca para cambiar)' : 'Normal (toca para cambiar)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
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
                  OwnershipBadge(label: 'Normal', owned: service.hasNormal.value),
                  const SizedBox(width: 24),
                  OwnershipBadge(label: 'Shiny', owned: service.hasShiny.value),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
