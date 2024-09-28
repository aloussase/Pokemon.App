import '../models/Pokemon.dart';

abstract class PokemonRepository {
  Stream<List<Pokemon>> get pokemon;

  Future<void> loadPokemon();
}
