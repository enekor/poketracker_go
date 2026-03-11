// lib/core/constants/pokemon_generations.dart

const Map<int, Map<String, dynamic>> pokemonGenerations = {
  1: {'name': 'Generación I - Kanto', 'start': 1, 'end': 151},
  2: {'name': 'Generación II - Johto', 'start': 152, 'end': 251},
  3: {'name': 'Generación III - Hoenn', 'start': 252, 'end': 386},
  4: {'name': 'Generación IV - Sinnoh', 'start': 387, 'end': 493},
  5: {'name': 'Generación V - Unova', 'start': 494, 'end': 649},
  6: {'name': 'Generación VI - Kalos', 'start': 650, 'end': 721},
  7: {'name': 'Generación VII - Alola', 'start': 722, 'end': 809},
  8: {'name': 'Generación VIII - Galar', 'start': 810, 'end': 905},
  9: {'name': 'Generación IX - Paldea', 'start': 906, 'end': 1025},
};

/// Returns the generation number for a given Pokémon ID.
int getGeneration(int pokemonId) {
  for (final entry in pokemonGenerations.entries) {
    final start = entry.value['start'] as int;
    final end = entry.value['end'] as int;
    if (pokemonId >= start && pokemonId <= end) {
      return entry.key;
    }
  }
  return 1;
}
