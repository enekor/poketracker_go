// lib/core/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:poketracker_go/core/models/user_pokemon_model.dart';
import 'package:poketracker_go/core/models/settings_model.dart';

class HiveService {
  static const String userPokemonBoxName = 'user_pokemon';
  static const String settingsBoxName = 'settings';

  late Box<UserPokemonModel> userPokemonBox;
  late Box<SettingsModel> settingsBox;

  /// Initialize Hive, register adapters, and open boxes.
  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserPokemonModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());

    userPokemonBox = await Hive.openBox<UserPokemonModel>(userPokemonBoxName);
    settingsBox = await Hive.openBox<SettingsModel>(settingsBoxName);
  }

  // --- User Pokémon CRUD ---

  UserPokemonModel? getUserPokemon(int pokemonId) {
    return userPokemonBox.get(pokemonId);
  }

  Map<int, UserPokemonModel> getAllUserPokemon() {
    final map = <int, UserPokemonModel>{};
    for (final entry in userPokemonBox.toMap().entries) {
      map[entry.key as int] = entry.value;
    }
    return map;
  }

  Future<void> saveUserPokemon(UserPokemonModel model) async {
    await userPokemonBox.put(model.pokemonId, model);
  }

  Future<void> saveAllUserPokemon(List<UserPokemonModel> models) async {
    final map = <int, UserPokemonModel>{};
    for (final m in models) {
      map[m.pokemonId] = m;
    }
    await userPokemonBox.putAll(map);
  }

  // --- Settings ---

  SettingsModel getSettings() {
    return settingsBox.get('main', defaultValue: SettingsModel())!;
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await settingsBox.put('main', settings);
  }
}
