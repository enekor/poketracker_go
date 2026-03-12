// lib/app/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poketracker_go/app/theme/app_theme.dart';
import 'package:poketracker_go/core/services/hive_service.dart';

class ThemeController extends GetxController {
  final HiveService _hiveService = Get.find<HiveService>();
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    final settings = _hiveService.getSettings();
    isDarkMode.value = settings.isDarkMode;
    _applyTheme();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _applyTheme();
    final settings = _hiveService.getSettings();
    settings.isDarkMode = isDarkMode.value;
    _hiveService.saveSettings(settings);
  }

  void _applyTheme() {
    Get.changeTheme(isDarkMode.value ? AppTheme.dark : AppTheme.light);
  }
}
