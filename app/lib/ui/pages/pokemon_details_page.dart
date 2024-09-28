import 'package:flutter/material.dart';

final class PokemonDetailsPage extends StatefulWidget {
  String name;

  PokemonDetailsPage(this.name, {super.key});

  static Route<PokemonDetailsPage> route(String name) {
    return MaterialPageRoute(
      builder: (_) => PokemonDetailsPage(name),
    );
  }

  @override
  State<StatefulWidget> createState() => _PokemonDetailsPageState();
}

final class _PokemonDetailsPageState extends State<PokemonDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(widget.name),
    );
  }
}
