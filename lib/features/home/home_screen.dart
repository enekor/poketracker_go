// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
import 'package:poketracker_go/app/theme/theme_controller.dart';
import 'package:poketracker_go/features/home/home_service.dart';
import 'package:poketracker_go/features/home/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(HomeService());
    final themeController = Get.find<ThemeController>();
    final spriteController = Get.find<SpriteStyleController>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PokéTracker GO',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: themeController.toggleTheme,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const PokeballBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, Entrenador!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu progreso actual en la Pokédex.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main Progress Card
                  Obx(
                    () => GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem(
                                  context,
                                  'NORMAL',
                                  service.totalOwned.value,
                                  service.totalPokemon,
                                  Icons.catching_pokemon,
                                  theme.colorScheme.primary,
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.1),
                                ),
                                _buildStatItem(
                                  context,
                                  'SHINY',
                                  service.totalShiny.value,
                                  service.totalPokemon,
                                  Icons.auto_awesome,
                                  theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value:
                                    service.totalOwned.value /
                                    service.totalPokemon,
                                minHeight: 12,
                                backgroundColor: theme.colorScheme.onSurface
                                    .withOpacity(0.05),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text(
                    'ACCESO RÁPIDO',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Navigation Hub
                  Row(
                    children: [
                      Expanded(
                        child: HubTile(
                          title: 'Pokédex',
                          subtitle: 'Ver colección',
                          icon: Icons.menu_book_rounded,
                          color: theme.colorScheme.primary,
                          onTap: () async {
                            await Get.toNamed(AppRoutes.pokedex);
                            service.refreshStats();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: HubTile(
                          title: 'Capturas',
                          subtitle: 'Registrar nuevos',
                          icon: Icons.add_task_rounded,
                          color: theme.colorScheme.secondary,
                          onTap: () async {
                            await Get.toNamed(AppRoutes.pokemonSelector);
                            service.refreshStats();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => HubTile(
                      title: spriteController.usePixelArt.value
                          ? 'Pixel Art'
                          : '3D Sprites',
                      subtitle: 'Cambiar estilo',
                      iconWidget: SizedBox(
                        width: 28,
                        height: 28,
                        child: CachedNetworkImage(
                          imageUrl: spriteController.pikachuSpriteUrl,
                          fit: BoxFit.contain,
                          filterQuality: spriteController.usePixelArt.value
                              ? FilterQuality.none
                              : FilterQuality.low,
                          placeholder: (_, __) => const SizedBox.shrink(),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.catching_pokemon,
                            size: 28,
                          ),
                        ),
                      ),
                      color: Colors.orange,
                      onTap: spriteController.toggleStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    int total,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count / $total',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
