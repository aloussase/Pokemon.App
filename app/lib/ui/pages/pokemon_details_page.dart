import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/init.dart';
import '../../domain/models/pokemon_stat.dart';
import '../viewmodel/pokemon_details_view_model.dart';
import '../viewmodel/snackbar_view_model.dart';

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
            Navigator.of(context).push(PokemonDetailsPage.route(name));
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
    return Scaffold(
      body: BlocBuilder<PokemonDetailsViewModel, PokemonDetailsState>(
        builder: (context, state) {
          if (state.status == PokemonDetailsStatus.loading ||
              state.status == PokemonDetailsStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image(image: NetworkImage(state.pokemon!.imageUrl)),
                    Text(
                      state.pokemon!.name.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text("Tipos"),
                    Types(types: state.pokemon!.types),
                    const SizedBox(height: 18),
                    const Text("Stats"),
                    Stats(stats: state.pokemon!.stats),
                    const SizedBox(height: 18),
                    const Text("Habilidades"),
                    Abilities(abilities: state.pokemon!.abilities),
                    const SizedBox(height: 18),
                    const Text("Línea evolutiva"),
                    EvolutionChain(evolutions: state.pokemon!.evolutions),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PokemonDetailsViewModel>().add(OnEvolve());
                      },
                      child: const Text("Evolucionar"),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
    return Wrap(
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
    );
  }
}

class Stats extends StatelessWidget {
  final List<PokemonStat> stats;

  const Stats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 4,
      children: [
        for (final stat in stats)
          Badge(
            padding: const EdgeInsets.all(6),
            label: Text("${stat.name} ${stat.value}"),
          )
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
    return Wrap(
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
    );
  }
}

class EvolutionChain extends StatelessWidget {
  final List<String> evolutions;

  const EvolutionChain({
    super.key,
    required this.evolutions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (ix, evo) in evolutions.indexed)
          Row(
            children: [
              Text(evo.toUpperCase()),
              const SizedBox(width: 5),
              if (ix < evolutions.length - 1)
                const Icon(Icons.arrow_right_alt_sharp),
              const SizedBox(width: 5),
            ],
          )
      ],
    );
  }
}
