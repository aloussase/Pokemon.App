import '../models/pokemon_details.dart';
import '../repository/pokemon_repository.dart';

final class GetPokemonDetailsUseCase {
  final PokemonRepository _pokemon;

  GetPokemonDetailsUseCase(this._pokemon);

  Future<PokemonDetails> call(String name) => _pokemon.getPokemonDetails(name);
}
