// lib/features/settings/settings_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/core/services/hive_service.dart';
import 'package:share_plus/share_plus.dart';

class SettingsService extends GetxController {
  final HiveService hiveService = Get.find<HiveService>();

  /// Exports the user's collection to a JSON file and shares it.
  Future<void> exportData() async {
    try {
      final userData = hiveService.getAllUserPokemon();
      if (userData.isEmpty) {
        Get.snackbar('Información', 'No hay datos para exportar');
        return;
      }

      final List<Map<String, dynamic>> jsonData = userData.values
          .map((m) => {
                'id': m.pokemonId,
                'n': m.hasNormal,
                's': m.hasShiny,
              })
          .toList();

      final String jsonString = jsonEncode(jsonData);
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/poketracker_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Copia de seguridad PokéTracker GO',
        text: 'Aquí tienes tu copia de seguridad de PokéTracker GO.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Error al exportar: $e');
    }
  }

  /// Imports the user's collection from a JSON file using file_picker.
  Future<void> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final List<UserPokemonModel> models = [];
      for (final item in data) {
        models.add(UserPokemonModel(
          pokemonId: item['id'] as int,
          hasNormal: item['n'] as bool,
          hasShiny: item['s'] as bool,
        ));
      }

      if (models.isNotEmpty) {
        await hiveService.saveAllUserPokemon(models);
        Get.snackbar('Éxito', '¡Datos importados correctamente!');
      } else {
        Get.snackbar('Aviso', 'El archivo no contiene datos válidos');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al importar: $e');
    }
  }
}
