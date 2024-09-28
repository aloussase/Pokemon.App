import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/pokemon.dart';
import '../../domain/repository/pokemon_repository.dart';
import '../../domain/use_case/get_pokemon_use_case.dart';

enum HomeStatus {
  initial,
  loading,
  success,
}

final class HomeState {
  final List<Pokemon> pokemon;
  final HomeStatus status;

  HomeState({required this.pokemon, required this.status});

  factory HomeState.empty() => HomeState(
        pokemon: [],
        status: HomeStatus.initial,
      );

  HomeState copyWith({List<Pokemon>? pokemon, HomeStatus? status}) => HomeState(
        pokemon: pokemon ?? this.pokemon,
        status: status ?? this.status,
      );
}

sealed class HomeEvent {}

final class OnPokemonListSubscriptionRequested extends HomeEvent {}

final class HomeViewModel extends Bloc<HomeEvent, HomeState> {
  final GetPokemonUseCase _getPokemon;
  final PokemonRepository _pokemon;

  HomeViewModel(this._getPokemon, this._pokemon) : super(HomeState.empty()) {
    on<OnPokemonListSubscriptionRequested>((evt, emit) async {
      emit(state.copyWith(status: HomeStatus.loading));
      await _pokemon.loadPokemon();
      emit(state.copyWith(status: HomeStatus.success));
      await emit.forEach(
        _getPokemon(),
        onData: (pokemon) => state.copyWith(pokemon: pokemon),
      );
    });
  }
}
