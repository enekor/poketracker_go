// lib/core/models/settings_model.dart

import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool usePixelArt;

  SettingsModel({this.isDarkMode = false, this.usePixelArt = true});
}
