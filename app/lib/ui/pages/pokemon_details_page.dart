import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/init.dart';
import '../../domain/models/pokemon.dart';
import '../../domain/models/pokemon_stat.dart';
import '../viewmodel/pokemon_details_view_model.dart';
import '../viewmodel/snackbar_view_model.dart';
import '../widgets/bottom_navigation.dart';

final class PokemonDetailsPage extends StatefulWidget {
  String name;

  PokemonDetailsPage(this.name, {super.key});

  static Route<PokemonDetailsPage> route(String name) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider<PokemonDetailsViewModel>(
        create: (_) => getIt()..add(OnLoadPokemonDetails(name)),
        child: PokemonDetailsPage(name),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _PokemonDetailsPageState();
}

final class _PokemonDetailsPageState extends State<PokemonDetailsPage> {
  late final StreamSubscription<String> _snackbarSubscription;
  late final StreamSubscription<PokemonDetailsUiEvent> _uiEvents;

  @override
  void initState() {
    super.initState();

    final snackbarViewModel = context.read<SnackbarViewModel>();
    final detailsViewModel = context.read<PokemonDetailsViewModel>();

    _uiEvents = detailsViewModel.uiEvents.listen(
      (event) {
        switch (event) {
          case OnUnableToEvolve():
            snackbarViewModel.add(
              OnSnackbarMessage(
                message: "El Pokemon ya no puede evolucionar",
              ),
            );
          case OnEvolved(name: final name):
            snackbarViewModel.add(
              OnSnackbarMessage(message: "¡El Pokemon va a evolucionar!"),
            );
            Future.delayed(
              const Duration(seconds: 2),
              () {
                Navigator.of(context).push(PokemonDetailsPage.route(name));
              },
            );
          case OnError():
            snackbarViewModel.add(
              OnSnackbarMessage(
                message: event.message,
              ),
            );
          case OnAddedToFavorites():
            snackbarViewModel.add(
              OnSnackbarMessage(
                message:
                    "${event.name} ha sido añadido a tu lista de favoritos",
              ),
            );
        }
      },
    );

    _snackbarSubscription = snackbarViewModel.messages.listen(
      (message) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _snackbarSubscription.cancel();
    _uiEvents.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonDetailsViewModel, PokemonDetailsState>(
      builder: (context, state) {
        if (state.status == PokemonDetailsStatus.loading ||
            state.status == PokemonDetailsStatus.initial) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Cargando información del Pokemon")
                ],
              ),
            ),
          );
        }

        return Scaffold(
          bottomNavigationBar: const BottomNavigation(),
          bottomSheet: BottomSheet(
            constraints: const BoxConstraints(
              maxHeight: 350,
            ),
            enableDrag: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            onClosing: () {},
            builder: (BuildContext context) {
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: "Estadísticas"),
                        Tab(text: "Evoluciones"),
                      ],
                    ),
                    SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TabBarView(
                          children: [
                            Stats(
                              stats: state.pokemon!.stats,
                            ),
                            EvolutionChain(
                              evolutions: state.pokemon!.evolutions,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.pokemon!.name.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context
                                    .read<PokemonDetailsViewModel>()
                                    .add(OnStar());
                              },
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        Types(types: state.pokemon!.types),
                        const SizedBox(height: 4),
                        Abilities(abilities: state.pokemon!.abilities),
                      ],
                    ),
                    Center(
                      child: Image(
                        image: NetworkImage(state.pokemon!.imageUrl),
                        height: 300,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Types extends StatelessWidget {
  final List<String> types;

  const Types({
    super.key,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Tipos",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            for (final type in types)
              Badge(
                padding: const EdgeInsets.all(6),
                label: Text(type),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              )
          ],
        ),
      ],
    );
  }
}

class Stats extends StatelessWidget {
  final List<PokemonStat> stats;

  const Stats({
    super.key,
    required this.stats,
  });

  String _getStatName(String name) => switch (name) {
        "hp" => "HP",
        "attack" => "Ataque",
        "defense" => "Defensa",
        "special-attack" => "Ataque especial",
        "special-defense" => "Defensa especial",
        "speed" => "Velocidad",
        _ => ""
      };

  Color _getStatColor(int value) => switch (value) {
        < 50 => Colors.red,
        _ => Colors.green,
      };

  @override
  Widget build(BuildContext context) {
    const maxWidth = 180;
    final maxValue = stats.map((stat) => stat.value).reduce(max);
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 4,
      mainAxisSpacing: 2,
      children: [
        for (final stat in stats) ...[
          Text(_getStatName(stat.name)),
          Row(
            children: [
              Container(
                width: maxWidth * (stat.value / maxValue),
                height: 20,
                decoration: BoxDecoration(
                  color: _getStatColor(stat.value),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  stat.value.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ]
      ],
    );
  }
}

class Abilities extends StatelessWidget {
  final List<String> abilities;

  const Abilities({
    super.key,
    required this.abilities,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Habilidades",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            for (final ability in abilities)
              Badge(
                padding: const EdgeInsets.all(6),
                label: Text(ability),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              )
          ],
        ),
      ],
    );
  }
}

class EvolutionChain extends StatelessWidget {
  final List<Pokemon> evolutions;

  const EvolutionChain({
    super.key,
    required this.evolutions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final (ix, evo) in evolutions.indexed)
              Row(
                children: [
                  Column(
                    children: [
                      Image(
                        image: NetworkImage(evo.imageUrl),
                        width: 85,
                      ),
                      Text(evo.name.toUpperCase())
                    ],
                  ),
                  const SizedBox(width: 5),
                  if (ix < evolutions.length - 1)
                    const Icon(Icons.arrow_right_alt_sharp),
                  const SizedBox(width: 5),
                ],
              ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          child: const Text("Evolucionar"),
          onPressed: () =>
              context.read<PokemonDetailsViewModel>().add(OnEvolve()),
        )
      ],
    );
  }
}
