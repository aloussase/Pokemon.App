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

final class LoginState {
  String username;
  String password;

  LoginState({
    required this.username,
    required this.password,
  });

  factory LoginState.empty() => LoginState(
        username: "",
        password: "",
      );

  LoginState copyWith({String? username, String? password, String? error}) =>
      LoginState(
        username: username ?? this.username,
        password: password ?? this.password,
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
    final result = await _loginUseCase(
      state.username,
      state.password,
    );

    switch (result) {
      case Left(value: var loginError):
        _errors.add(loginError.message);
      case Right(value: var accessToken):
        print(accessToken);
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
