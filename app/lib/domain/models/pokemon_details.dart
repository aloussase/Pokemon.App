import 'pokemon.dart';
import 'pokemon_stat.dart';

final class PokemonDetails {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;
  final List<Pokemon> evolutions;

  PokemonDetails(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.types,
      required this.abilities,
      required this.stats,
      required this.evolutions});
}
