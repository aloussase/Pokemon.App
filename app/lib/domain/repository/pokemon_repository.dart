import '../models/pokemon.dart';
import '../models/pokemon_details.dart';

abstract class PokemonRepository {
  Stream<List<Pokemon>> get pokemon;

  Future<void> loadPokemon();

  Future<PokemonDetails> getPokemonDetails(String name);
}
