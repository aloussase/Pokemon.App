import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/use_case/login_use_case.dart';

sealed class LoginEvent {}

final class OnUsernameChanged extends LoginEvent {
  final String value;

  OnUsernameChanged(this.value);
}

final class OnPasswordChanged extends LoginEvent {
  final String value;

  OnPasswordChanged(this.value);
}

final class OnLogin extends LoginEvent {}

enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

final class LoginState {
  String username;
  String password;
  LoginStatus status;

  LoginState({
    required this.username,
    required this.password,
    required this.status,
  });

  factory LoginState.empty() => LoginState(
        username: "",
        password: "",
        status: LoginStatus.initial,
      );

  LoginState copyWith({
    String? username,
    String? password,
    String? error,
    LoginStatus? status,
  }) =>
      LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
        status: status ?? this.status,
      );
}

final class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  final StreamController<String> _errors = StreamController<String>.broadcast();

  Stream<String> get errors => _errors.stream;

  void dispose() => _errors.close();

  LoginViewModel(this._loginUseCase) : super(LoginState.empty()) {
    on<OnUsernameChanged>(_onUsernameChanged);
    on<OnPasswordChanged>(_onPasswordChanged);
    on<OnLogin>(_onLogin);
  }

  FutureOr<void> _onLogin(OnLogin evt, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _loginUseCase(
      state.username,
      state.password,
    );

    switch (result) {
      case Left(value: var loginError):
        _errors.add(loginError.message);
        emit(state.copyWith(status: LoginStatus.error));
      case Right():
        emit(state.copyWith(status: LoginStatus.success));
    }
  }

  FutureOr<void> _onUsernameChanged(
    OnUsernameChanged evt,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        username: evt.value,
      ),
    );
  }

  FutureOr<void> _onPasswordChanged(
    OnPasswordChanged evt,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: evt.value,
      ),
    );
  }
}
