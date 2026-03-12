// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/routes/app_routes.dart';
import 'package:poketracker_go/app/theme/app_theme.dart';
import 'package:poketracker_go/app/theme/sprite_style_controller.dart';
import 'package:poketracker_go/app/theme/theme_controller.dart';
import 'package:poketracker_go/core/services/api_service.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Register global services
  Get.put(hiveService);
  Get.put(ApiService());
  Get.put(ThemeController());
  Get.put(SpriteStyleController());

  runApp(const PokeTrackerApp());
}

class PokeTrackerApp extends StatelessWidget {
  const PokeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'PokéTracker GO',
        debugShowCheckedModeBanner: false,
        theme: themeController.isDarkMode.value ? AppTheme.dark : AppTheme.light,
        initialRoute: AppRoutes.home,
        getPages: AppRoutes.pages,
      ),
    );
  }
}
