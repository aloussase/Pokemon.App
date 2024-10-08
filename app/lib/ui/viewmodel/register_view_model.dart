import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_case/register_use_case.dart';

sealed class RegisterEvent {}

final class OnUsernameChanged extends RegisterEvent {
  final String value;

  OnUsernameChanged(this.value);
}

final class OnPasswordChanged extends RegisterEvent {
  final String value;

  OnPasswordChanged(this.value);
}

final class OnRegister extends RegisterEvent {}

enum RegisterStatus {
  initial,
  loading,
  success,
  error,
}

final class RegisterState {
  final String username;
  final String password;
  final RegisterStatus status;

  RegisterState(this.username, this.password, this.status);

  factory RegisterState.empty() =>
      RegisterState("", "", RegisterStatus.initial);

  RegisterState copyWith({
    String? username,
    String? password,
    RegisterStatus? status,
  }) =>
      RegisterState(
        username ?? this.username,
        password ?? this.password,
        status ?? this.status,
      );
}

final class RegisterViewModel extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _register;

  final StreamController<String> _errors = StreamController<String>.broadcast();

  Stream<String> get errors => _errors.stream;

  @override
  Future<void> close() {
    _errors.close();
    return super.close();
  }

  RegisterViewModel(this._register) : super(RegisterState.empty()) {
    on<OnUsernameChanged>(_onUsernameChanged);
    on<OnPasswordChanged>(_onPasswordChanged);
    on<OnRegister>(_onRegister);
  }

  FutureOr<void> _onRegister(
    OnRegister evt,
    Emitter<RegisterState> emit,
  ) async {
    final username = state.username;
    final password = state.password;

    emit(state.copyWith(status: RegisterStatus.loading));
    final result = await _register(username, password);

    if (result != null) {
      _errors.add(result.message);
      emit(state.copyWith(status: RegisterStatus.error));
    } else {
      emit(state.copyWith(status: RegisterStatus.success));
    }
  }

  FutureOr<void> _onUsernameChanged(
    OnUsernameChanged evt,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        username: evt.value,
      ),
    );
  }

  FutureOr<void> _onPasswordChanged(
    OnPasswordChanged evt,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        password: evt.value,
      ),
    );
  }
}
