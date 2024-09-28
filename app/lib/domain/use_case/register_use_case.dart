
import '../repository/auth_repository.dart';

class RegisterError {
  final String message;

  RegisterError(this.message);
}

final class RegisterUseCase {
  final AuthRepository _auth;

  RegisterUseCase(this._auth);

  Future<RegisterError?> call(
    String username,
    String password,
  ) async {
    if (username.isEmpty) {
      return RegisterError("El usuario es obligatorio");
    }

    if (password.isEmpty) {
      return RegisterError("La contraseña es obligatoria");
    }

    final result = await _auth.register(username, password);

    if (result != null) {
      return RegisterError(result.message);
    }

    return null;
  }
}
