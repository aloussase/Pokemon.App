import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/init.dart';
import '../viewmodel/home_view_model.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/pokemon_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route<HomePage> route() {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
    );
  }

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeViewModel>(
      create: (_) => getIt()..add(OnPokemonListSubscriptionRequested()),
      child: Scaffold(
        bottomNavigationBar: const BottomNavigation(),
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

            return PokemonListView(
              pokemon: state.pokemon,
              onReloadPokemon: () {
                context
                    .read<HomeViewModel>()
                    .add(OnPokemonListSubscriptionRequested());
              },
            );
          },
        ),
      ),
    );
  }
}
