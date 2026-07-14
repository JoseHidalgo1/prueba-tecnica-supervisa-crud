class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> types;
  final List<PokemonStats> stats;
  final List<String> abilities;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final officialArtwork = sprites == null
        ? null
        : (sprites['other'] as Map<String, dynamic>?)?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: (json['types'] as List)
          .cast<Map<String, dynamic>>()
          .map((typeJson) => typeJson['type']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .cast<Map<String, dynamic>>()
          .map((statJson) => PokemonStats.fromJson(statJson))
          .toList(),
      abilities: (json['abilities'] as List)
          .cast<Map<String, dynamic>>()
          .map((abilityJson) => abilityJson['ability']['name'] as String)
          .toList(),
      imageUrl: officialArtwork == null
          ? ''
          : officialArtwork['front_default'] as String? ?? '',
    );
  }
}

class PokemonStats {
  final String name;
  final int baseStat;

  const PokemonStats({
    required this.name,
    required this.baseStat,
  });

  factory PokemonStats.fromJson(Map<String, dynamic> json) {
    return PokemonStats(
      name: json['stat']['name'] as String,
      baseStat: json['base_stat'] as int,
    );
  }
}
