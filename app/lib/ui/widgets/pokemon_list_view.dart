import 'package:flutter/material.dart';

import '../../domain/models/pokemon.dart';
import '../pages/pokemon_details_page.dart';

class PokemonListView extends StatelessWidget {
  final List<Pokemon> pokemon;
  final VoidCallback onReloadPokemon;

  const PokemonListView({
    super.key,
    required this.pokemon,
    required this.onReloadPokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Scrollbar(
        child: ListView(
          children: [
            if (pokemon.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("No hay Pokemon que mostrar"),
                    ElevatedButton(
                      onPressed: onReloadPokemon,
                      child: const Text("Recargar"),
                    )
                  ],
                ),
              ),
            for (final pokemon in pokemon)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PokemonDetailsPage.route(pokemon.name),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image(
                          image: NetworkImage(pokemon.imageUrl),
                          height: 160,
                          fit: BoxFit.fitHeight,
                        ),
                        Text(
                          pokemon.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
