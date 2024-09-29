import 'package:flutter/material.dart';

class FavoritePokemonPage extends StatefulWidget {
  const FavoritePokemonPage({super.key});

  static Route<FavoritePokemonPage> route() {
    return MaterialPageRoute(
      builder: (_) => const FavoritePokemonPage(),
    );
  }

  @override
  State<FavoritePokemonPage> createState() => _FavoritePokemonPageState();
}

class _FavoritePokemonPageState extends State<FavoritePokemonPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
