import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';

import '../../domain/repository/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  final Client _client;
  final _controller = StreamController<AuthState>();

  // TODO: Move this to a configuration object.
  static const API_BASE = "http://192.168.60.251:3000";

  AuthRepositoryImpl({required Client httpClient}) : _client = httpClient;

  @override
  Future<Either<AuthError, String>> login(
      String username, String password) async {
    final response = await _client.post(
      Uri.parse("$API_BASE/api/login"),
      body: jsonEncode(
        {
          "username": username,
          "password": password,
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      final jsonBody = jsonDecode(response.body);
      final message = jsonBody["errors"][0];
      return Either.left(AuthError(message));
    }

    final jsonBody = jsonDecode(response.body);
    final accessToken = jsonBody["data"]["accessToken"];

    _controller.add(
      Authenticated(
        accessToken: accessToken,
        username: username,
      ),
    );

    return Either.right(accessToken);
  }

  @override
  Future<AuthError?> register(String username, String password) async {
    final response = await _client.post(
      Uri.parse("$API_BASE/api/register"),
      body: jsonEncode(
        {
          "username": username,
          "password": password,
        },
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      final jsonBody = jsonDecode(response.body);
      final message = jsonBody["errors"][0];
      return AuthError(message);
    }

    final jsonBody = jsonDecode(response.body);
    final accessToken = jsonBody["data"]["accessToken"];

    _controller.add(
      Authenticated(
        accessToken: accessToken,
        username: username,
      ),
    );

    return null;
  }

  @override
  Stream<AuthState> get authState async* {
    yield Unauthenticated();
    yield* _controller.stream;
  }

  @override
  void dispose() {
    _controller.close();
  }
}
