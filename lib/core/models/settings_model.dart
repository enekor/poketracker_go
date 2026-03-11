// lib/core/models/settings_model.dart

import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  SettingsModel({this.isDarkMode = false});
}
