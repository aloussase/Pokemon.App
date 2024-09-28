import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/auth_repository.dart';

sealed class AuthEvent {}

final class AuthStateChanged extends AuthEvent {
  final AuthState state;

  AuthStateChanged(this.state);
}

final class AuthViewModel extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<AuthState> _authStateSubscription;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(Unauthenticated()) {
    on<AuthStateChanged>(_onAuthStateChanged);

    _authStateSubscription = _authRepository.authState.listen(
      (state) {
        add(AuthStateChanged(state));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  FutureOr<void> _onAuthStateChanged(
    AuthStateChanged evt,
    Emitter<AuthState> emit,
  ) {
    print("_onAuthStateChanged");
    emit(evt.state);
  }
}
