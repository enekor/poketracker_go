// lib/features/pokemon_detail/pokemon_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
import 'package:poketracker_go/core/widgets/skeleton.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_service.dart';
import 'package:poketracker_go/features/pokemon_detail/pokemon_detail_widgets.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(PokemonDetailService());
    final activeVariant = 0.obs; // 0=Normal,1=Shiny,2=Shadow,3=Purified,4=ShadowShiny,5=PurifiedShiny
    final showFemale = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(service.capitalizedName())),
        centerTitle: true,
      ),
      body: Obx(() {
        if (service.isLoading.value) {
          return const PokemonDetailSkeleton();
        }

        final pokemon = service.pokemon.value;
        if (pokemon == null) {
          return const Center(child: Text('Pokémon no encontrado'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final spriteCtrl = Get.find<SpriteStyleController>();
            final isPixelArt = spriteCtrl.usePixelArt.value;
            final hasGender = service.hasFemaleSprite.value;
            final variant = activeVariant.value;
            final isShinyVariant = variant == 1 || variant == 4 || variant == 5;

            // Compute sprite URL
            String spriteUrl;
            if (showFemale.value) {
              if (isPixelArt) {
                spriteUrl = isShinyVariant
                    ? (pokemon.spriteShinyFemaleUrl ?? pokemon.spriteShinyUrl)
                    : (pokemon.spriteFemaleUrl ?? pokemon.spriteUrl);
              } else {
                spriteUrl = isShinyVariant
                    ? (pokemon.spriteHomeShinyFemaleUrl ??
                        spriteCtrl.spriteShinyUrl(pokemon.id))
                    : (pokemon.spriteHomeFemaleUrl ??
                        spriteCtrl.spriteUrl(pokemon.id));
              }
            } else {
              spriteUrl = isShinyVariant
                  ? spriteCtrl.spriteShinyUrl(pokemon.id)
                  : spriteCtrl.spriteUrl(pokemon.id);
            }

            return Column(
              children: [
                // 1. Sprite
                PokemonSpriteViewer(
                  spriteUrl: spriteUrl,
                  usePixelArt: isPixelArt,
                ),

                // 2. Gender selector (only if gender difference exists)
                if (hasGender) ...[
                  const SizedBox(height: 12),
                  GenderSelector(
                    isFemale: showFemale.value,
                    onTap: () => showFemale.value = !showFemale.value,
                  ),
                ],

                // 3. Pokédex number — Name
                const SizedBox(height: 16),
                Text(
                  '${pokemon.formattedId} — ${service.capitalizedName()}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // 4. Types
                if (pokemon.types.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children:
                        pokemon.types.map((t) => TypeChip(type: t)).toList(),
                  ),
                ],

                // 5. Variant selector (only unlocked ones are selectable)
                const SizedBox(height: 24),
                OwnershipToggle(
                  variants: {
                    0: service.hasNormal.value,
                    1: service.hasShiny.value,
                    2: service.hasShadow.value,
                    3: service.hasPurified.value,
                    4: service.hasShadowShiny.value,
                    5: service.hasPurifiedShiny.value,
                  },
                  activeVariant: activeVariant.value,
                  onVariantTap: (v) => activeVariant.value = v,
                ),

                // 6. Evolution chain
                if (!service.isLoadingEvolution.value &&
                    service.evolutionChain.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  EvolutionChainWidget(
                    stages: service.evolutionChain,
                    currentPokemonId: pokemon.id,
                    onTap: (entry) {
                      showShiny.value = false;
                      showFemale.value = false;
                      service.loadPokemon(entry.id, entry.name);
                    },
                  ),
                ],
              ],
            );
          }),
        );
      }),
    );
  }
}
