import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_details.dart';
import '../../domain/models/pokemon_stat.dart';
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

  static const POKEAPI_EVOLUTION_ENDPOINT =
      "https://pokeapi.co/api/v2/evolution-chain/";

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

    List<String> evolutions = [];

    var evolutionsResponse = await _client
        .get(Uri.parse(POKEAPI_EVOLUTION_ENDPOINT + json["id"].toString()));

    Map<String, dynamic> evolutionsJson = jsonDecode(evolutionsResponse.body);
    List<dynamic> evolvesTo = evolutionsJson["chain"]["evolves_to"];

    while (evolvesTo.isNotEmpty) {
      final species = evolvesTo[0]["species"]["name"];
      evolutions.add(species);
      evolvesTo = evolvesTo[0]["evolves_to"];
    }

    return PokemonDetails(
      name: json["name"],
      imageUrl: imageUrl,
      types: types,
      abilities: abilities,
      stats: stats,
      evolutions: evolutions,
    );
  }
}
