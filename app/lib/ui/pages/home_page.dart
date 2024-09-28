import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/init.dart';
import '../viewmodel/home_view_model.dart';
import 'pokemon_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeViewModel>(
      create: (_) => getIt()..add(OnPokemonListSubscriptionRequested()),
      child: Scaffold(
        body: BlocBuilder<HomeViewModel, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Cargando Pokemon"),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8),
              child: Scrollbar(
                child: ListView(
                  children: [
                    Text(
                      "Pokemon",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (state.pokemon.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("No hay Pokemon que mostrar"),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<HomeViewModel>()
                                  .add(OnPokemonListSubscriptionRequested()),
                              child: const Text("Recargar"),
                            )
                          ],
                        ),
                      ),
                    for (final pokemon in state.pokemon)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PokemonDetailsPage.route(pokemon.name),
                          );
                        },
                        child: Card(
                          child: Column(
                            children: [
                              Image(
                                image: NetworkImage(pokemon.imageUrl),
                                height: 200,
                                fit: BoxFit.fitHeight,
                              ),
                              const Divider(),
                              Text(
                                pokemon.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
