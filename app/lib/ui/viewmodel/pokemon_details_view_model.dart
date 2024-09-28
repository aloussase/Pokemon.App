import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/pokemon_details.dart';
import '../../domain/use_case/get_pokemon_details_use_case.dart';

enum PokemonDetailsStatus {
  initial,
  loading,
  success,
}

final class PokemonDetailsState {
  final PokemonDetailsStatus status;
  final PokemonDetails? pokemon;

  PokemonDetailsState({required this.status, required this.pokemon});

  factory PokemonDetailsState.empty() => PokemonDetailsState(
        status: PokemonDetailsStatus.initial,
        pokemon: null,
      );

  PokemonDetailsState copyWith(
      {PokemonDetailsStatus? status, PokemonDetails? pokemon}) {
    return PokemonDetailsState(
      status: status ?? this.status,
      pokemon: pokemon,
    );
  }
}

sealed class PokemonDetailsEvent {}

final class OnLoadPokemonDetails extends PokemonDetailsEvent {
  final String name;

  OnLoadPokemonDetails(this.name);
}

final class OnEvolve extends PokemonDetailsEvent {}

sealed class PokemonDetailsUiEvent {}

final class OnEvolved extends PokemonDetailsUiEvent {
  final String name;

  OnEvolved(this.name);
}

final class OnUnableToEvolve extends PokemonDetailsUiEvent {}

final class PokemonDetailsViewModel
    extends Bloc<PokemonDetailsEvent, PokemonDetailsState> {
  final GetPokemonDetailsUseCase _getPokemonDetails;

  final StreamController<PokemonDetailsUiEvent> _controller =
      StreamController();

  Stream<PokemonDetailsUiEvent> get uiEvents => _controller.stream;

  PokemonDetailsViewModel(this._getPokemonDetails)
      : super(PokemonDetailsState.empty()) {
    on<OnLoadPokemonDetails>(_onLoadPokemonDetails);
    on<OnEvolve>(_onEvolve);
  }

  FutureOr<void> _onLoadPokemonDetails(
    OnLoadPokemonDetails event,
    Emitter<PokemonDetailsState> emit,
  ) async {
    emit(state.copyWith(status: PokemonDetailsStatus.loading));
    final pokemon = await _getPokemonDetails(event.name);
    emit(
      state.copyWith(
        status: PokemonDetailsStatus.success,
        pokemon: pokemon,
      ),
    );
  }

  FutureOr<void> _onEvolve(
    OnEvolve event,
    Emitter<PokemonDetailsState> emit,
  ) async {
    if (state.pokemon == null) return;

    final pokemon = state.pokemon!;
    final evolutions = pokemon.evolutions;
    final index = evolutions.indexOf(pokemon.name);

    if (index == -1) {
      return;
    }

    if (index + 1 >= evolutions.length) {
      return _controller.add(
        OnUnableToEvolve(),
      );
    }

    _controller.add(
      OnEvolved(
        evolutions[index + 1],
      ),
    );
  }
}
