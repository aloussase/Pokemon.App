final class AuthenticationTokenHolder {
  String? token;

  static AuthenticationTokenHolder? _instance;

  AuthenticationTokenHolder._();

  static AuthenticationTokenHolder the() {
    _instance ??= AuthenticationTokenHolder._();
    return _instance!;
  }
}
