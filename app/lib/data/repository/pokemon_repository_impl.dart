import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../../domain/models/Pokemon.dart';
import '../../domain/repository/pokemon_repository.dart';

final class PokemonRepositoryImpl extends PokemonRepository {
  final Client _client;

  final StreamController<List<Pokemon>> _controller = StreamController();

  @override
  Stream<List<Pokemon>> get pokemon => _controller.stream;

  PokemonRepositoryImpl(this._client);

  static const POKEAPI_POKEMON_ENDPOINT =
      "https://pokeapi.co/api/v2/pokemon?limit=20";
  static const POKEAPI_DETAILS_ENDPOINT = "https://pokeapi.co/api/v2/pokemon/";

  @override
  Future<void> loadPokemon() async {
    final response = await _client.get(Uri.parse(POKEAPI_POKEMON_ENDPOINT));
    final List<Future<Response>> requests = [];
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      final List<dynamic> results = json["results"];
      for (final item in results) {
        final name = item["name"];
        requests.add(_client.get(Uri.parse(POKEAPI_DETAILS_ENDPOINT + name)));
      }
    }
    final responses = await Future.wait(requests);
    final pokemon = <Pokemon>[];
    for (final response in responses) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final name = json["name"];
        final imageUrl =
            json["sprites"]["other"]["official-artwork"]["front_default"];
        pokemon.add(Pokemon(name, imageUrl));
      }
    }
    _controller.add(pokemon);
  }
}
