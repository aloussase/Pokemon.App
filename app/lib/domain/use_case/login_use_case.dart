import 'package:fpdart/fpdart.dart';

import '../repository/auth_repository.dart';

final class LoginError {
  final String message;

  LoginError(this.message);
}

final class LoginUseCase {
  final AuthRepository _auth;

  LoginUseCase(this._auth);

  Future<Either<LoginError, String>> call(
    String username,
    String password,
  ) async {
    if (username.isEmpty) {
      return Either.left(LoginError("El usuario es obligatorio"));
    }

    if (password.isEmpty) {
      return Either.left(LoginError("La contraseña es obligatoria"));
    }

    final result = await _auth.login(username, password);

    return switch (result) {
      Left(value: var error) => Either.left(LoginError(error.message)),
      Right(value: var accessToken) => Either.right(accessToken)
    };
  }
}
