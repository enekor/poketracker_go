// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/routes/app_routes.dart';
import 'package:poketracker_go/app/theme/theme_controller.dart';
import 'package:poketracker_go/features/home/home_service.dart';
import 'package:poketracker_go/features/home/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.put(HomeService());
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PokéTracker GO'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: themeController.toggleTheme,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Stats cards
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Normal',
                      count: service.totalOwned.value,
                      total: service.totalPokemon,
                      icon: Icons.catching_pokemon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Shiny',
                      count: service.totalShiny.value,
                      total: service.totalPokemon,
                      icon: Icons.auto_awesome,
                      iconColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Navigation buttons
            MenuButton(
              label: 'Pokédex',
              icon: Icons.menu_book,
              onTap: () async {
                await Get.toNamed(AppRoutes.pokedex);
                service.refreshStats();
              },
            ),
            const SizedBox(height: 16),
            MenuButton(
              label: 'Registrar Pokémon',
              icon: Icons.add_circle_outline,
              onTap: () async {
                await Get.toNamed(AppRoutes.pokemonSelector);
                service.refreshStats();
              },
            ),
          ],
        ),
      ),
    );
  }
}
