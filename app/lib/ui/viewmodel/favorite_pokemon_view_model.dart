import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/pokemon.dart';
import '../../domain/repository/pokemon_repository.dart';

enum FavoritePokemonStatus { initial, loading, success }

final class FavoritePokemonState {
  final List<Pokemon> pokemon;
  final FavoritePokemonStatus status;

  FavoritePokemonState(this.pokemon, this.status);

  factory FavoritePokemonState.empty() {
    return FavoritePokemonState([], FavoritePokemonStatus.initial);
  }

  FavoritePokemonState copyWith({
    List<Pokemon>? pokemon,
    FavoritePokemonStatus? status,
  }) {
    return FavoritePokemonState(
      pokemon ?? this.pokemon,
      status ?? this.status,
    );
  }
}

sealed class FavoritePokemonEvent {}

final class OnLoadFavoritePokemon extends FavoritePokemonEvent {}

final class FavoritePokemonViewModel
    extends Bloc<FavoritePokemonEvent, FavoritePokemonState> {
  final PokemonRepository _pokemon;

  FavoritePokemonViewModel(this._pokemon)
      : super(FavoritePokemonState.empty()) {
    on<OnLoadFavoritePokemon>((evt, emit) async {
      emit(state.copyWith(status: FavoritePokemonStatus.loading));
      final subscription = emit.forEach(
        _pokemon.favoritePokemon,
        onData: (pokemon) => state.copyWith(pokemon: pokemon),
      );
      await _pokemon.loadFavoritePokemon();
      emit(state.copyWith(status: FavoritePokemonStatus.success));
      return subscription;
    });
  }
}
