import '../models/pokemon.dart';
import '../models/pokemon_details.dart';

abstract class PokemonRepository {
  Stream<List<Pokemon>> get pokemon;

  Future<void> loadPokemon();

  Future<PokemonDetails> getPokemonDetails(String name);

  Stream<List<Pokemon>> get favoritePokemon;

  Future<bool> loadFavoritePokemon();

  Future<void> saveFavoritePokemon(int pokemonId);
}
