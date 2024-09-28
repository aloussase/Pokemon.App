import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/init.dart';
import '../viewmodel/pokemon_details_view_model.dart';

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
    return BlocProvider(
      create: (context) => PokemonDetailsViewModel(getIt())
        ..add(OnLoadPokemonDetails(widget.name)),
      child: Scaffold(
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
                      Text(state.pokemon!.evolutions.length.toString()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
