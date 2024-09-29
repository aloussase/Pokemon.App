import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

import '../../config.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_details.dart';
import '../../domain/models/pokemon_stat.dart';
import '../../domain/repository/authentication_token_holder.dart';
import '../../domain/repository/pokemon_repository.dart';

final class PokemonRepositoryImpl extends PokemonRepository {
  final Client _client;

  final StreamController<List<Pokemon>> _controller =
      StreamController.broadcast();

  @override
  Stream<List<Pokemon>> get pokemon => _controller.stream;

  PokemonRepositoryImpl(this._client);

  static const POKEAPI_POKEMON_ENDPOINT =
      "https://pokeapi.co/api/v2/pokemon?limit=20";

  static const POKEAPI_DETAILS_ENDPOINT = "https://pokeapi.co/api/v2/pokemon/";

  static const POKEAPI_SPECIES_ENDPOINT =
      "https://pokeapi.co/api/v2/pokemon-species/";

  @override
  Future<void> loadPokemon() async {
    try {
      final offset = Random().nextInt(700);
      final response = await _client
          .get(Uri.parse("$POKEAPI_POKEMON_ENDPOINT&offset=$offset"))
          .timeout(const Duration(seconds: 10));
      final List<Future<Response>> requests = [];
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final List<dynamic> results = json["results"];
        for (final item in results) {
          final name = item["name"];
          requests.add(
            _client
                .get(Uri.parse(POKEAPI_DETAILS_ENDPOINT + name))
                .timeout(const Duration(seconds: 10)),
          );
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
    } catch (ex) {
      if (ex is! TimeoutException) {
        rethrow;
      }
    }
  }

  @override
  Future<PokemonDetails> getPokemonDetails(String name) async {
    var response =
        await _client.get(Uri.parse(POKEAPI_DETAILS_ENDPOINT + name));

    var json = jsonDecode(response.body);

    var imageUrl =
        json["sprites"]["other"]["official-artwork"]["front_default"];

    List<dynamic> jsonTypes = json["types"];
    List<dynamic> jsonAbilities = json["abilities"];
    List<dynamic> jsonStats = json["stats"];

    List<String> types =
        jsonTypes.map((type) => type["type"]["name"] as String).toList();

    List<String> abilities = jsonAbilities
        .map((ability) => ability["ability"]["name"] as String)
        .toList();

    List<PokemonStat> stats = jsonStats
        .map(
          (stat) => PokemonStat(
            name: stat["stat"]["name"],
            value: stat["base_stat"],
          ),
        )
        .toList();

    final evolutions = await _getEvolutionChain(name);

    return PokemonDetails(
      id: json["id"],
      name: json["name"],
      imageUrl: imageUrl,
      types: types,
      abilities: abilities,
      stats: stats,
      evolutions: evolutions,
    );
  }

  Future<List<Pokemon>> _getEvolutionChain(String name) async {
    List<Pokemon> evolutions = [];

    final uri = Uri.parse(POKEAPI_SPECIES_ENDPOINT + name);
    final response = await _client.get(uri);
    final json = jsonDecode(response.body);

    final evolutionChainUrl = json["evolution_chain"]["url"];
    final evolutionsResponse = await _client.get(Uri.parse(evolutionChainUrl));

    Map<String, dynamic> evolutionsJson = jsonDecode(evolutionsResponse.body);
    List<dynamic> evolvesTo = evolutionsJson["chain"]["evolves_to"];

    name = evolutionsJson["chain"]["species"]["name"];
    var imageUrl = await _getImageUrl(name);

    if (imageUrl != null) {
      evolutions.add(
        Pokemon(
          name,
          imageUrl,
        ),
      );
    }

    while (evolvesTo.isNotEmpty) {
      name = evolvesTo[0]["species"]["name"];
      imageUrl = await _getImageUrl(name);
      if (imageUrl != null) {
        evolutions.add(
          Pokemon(
            name,
            imageUrl,
          ),
        );
      }
      evolvesTo = evolvesTo[0]["evolves_to"];
    }

    return evolutions;
  }

  Future<String?> _getImageUrl(String name) async {
    try {
      final response = await _client
          .get(Uri.parse(POKEAPI_DETAILS_ENDPOINT + name))
          .timeout(const Duration(seconds: 10));
      final json = jsonDecode(response.body);
      final imageUrl =
          json["sprites"]["other"]["official-artwork"]["front_default"];
      return imageUrl;
    } catch (_) {
      return null;
    }
  }

  final _favoriteController = StreamController<List<Pokemon>>.broadcast();

  @override
  Stream<List<Pokemon>> get favoritePokemon => _favoriteController.stream;

  @override
  Future<bool> loadFavoritePokemon() async {
    final accessToken = AuthenticationTokenHolder.the().token;
    if (accessToken == null) {
      return false;
    }

    final response = await _client.get(
      Uri.parse("${Config.API_BASE_URL}/api/pokemon"),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }

    final json = jsonDecode(response.body);
    final List<dynamic> jsonList = json["data"];

    final pokemon =
        jsonList.map((p) => Pokemon(p["name"], p["imageUrl"])).toList();

    _favoriteController.add(pokemon);

    return true;
  }

  @override
  Future<void> saveFavoritePokemon(int pokemonId) async {
    final accessToken = AuthenticationTokenHolder.the().token;
    if (accessToken == null) {
      throw Exception("El usuario no se encuentra autenticado");
    }

    final response = await _client.post(
      Uri.parse("${Config.API_BASE_URL}/api/pokemon"),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'pokemonId': pokemonId}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final jsonBody = jsonDecode(response.body);
      final error = jsonBody["errors"][0];
      throw Exception(error);
    }
  }
}
