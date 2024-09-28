import '../../domain/models/Pokemon.dart';
import '../../domain/repository/pokemon_repository.dart';

final class GetPokemonUseCase {
  final PokemonRepository _pokemon;

  GetPokemonUseCase(this._pokemon);

  Stream<List<Pokemon>> call() => _pokemon.pokemon;
}
