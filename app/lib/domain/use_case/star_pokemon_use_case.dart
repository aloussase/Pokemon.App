import '../repository/pokemon_repository.dart';

final class StarPokemonError {
  final String message;

  StarPokemonError(this.message);
}

final class StarPokemonUseCase {
  final PokemonRepository _pokemon;

  StarPokemonUseCase(this._pokemon);

  Future<StarPokemonError?> call(int pokemonId) async {
    try {
      await _pokemon.saveFavoritePokemon(pokemonId);
      return null;
    } catch (ex) {
      return StarPokemonError(ex.toString());
    }
  }
}
