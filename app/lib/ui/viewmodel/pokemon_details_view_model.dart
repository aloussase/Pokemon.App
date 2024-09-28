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

final class PokemonDetailsViewModel
    extends Bloc<PokemonDetailsEvent, PokemonDetailsState> {
  final GetPokemonDetailsUseCase _getPokemonDetails;

  PokemonDetailsViewModel(this._getPokemonDetails)
      : super(PokemonDetailsState.empty()) {
    on<OnLoadPokemonDetails>(_onLoadPokemonDetails);
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
}
