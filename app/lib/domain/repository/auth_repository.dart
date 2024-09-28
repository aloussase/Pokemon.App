import 'package:fpdart/fpdart.dart';

sealed class AuthState {}

final class Unauthenticated extends AuthState {}

final class Authenticated extends AuthState {
  final String accessToken;
  final String username;

  Authenticated({required this.accessToken, required this.username});
}

final class AuthError {
  final String message;

  AuthError(this.message);
}

abstract class AuthRepository {
  /// Current auth state.
  Stream<AuthState> get authState;

  /// Perform login.
  /// @return The access token if successful.
  Future<Either<AuthError, String>> login(String username, String password);

  /// Perform registration
  Future<AuthError?> register(String username, String password);

  /// Dispose of this AuthRepository.
  void dispose() {}
}
