import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/init.dart';
import '../viewmodel/favorite_pokemon_view_model.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/pokemon_list_view.dart';

class FavoritePokemonPage extends StatefulWidget {
  const FavoritePokemonPage({super.key});

  static Route<FavoritePokemonPage> route() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider<FavoritePokemonViewModel>(
        create: (_) => getIt()..add(OnLoadFavoritePokemon()),
        child: const FavoritePokemonPage(),
      ),
    );
  }

  @override
  State<FavoritePokemonPage> createState() => _FavoritePokemonPageState();
}

class _FavoritePokemonPageState extends State<FavoritePokemonPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritePokemonViewModel, FavoritePokemonState>(
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: const BottomNavigation(selectedTab: 1),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Tus Pokemon favoritos",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Icon(Icons.favorite, color: Colors.red),
                    ],
                  ),
                ),
                Flexible(
                  child: PokemonListView(
                    pokemon: state.pokemon,
                    onReloadPokemon: () {
                      context
                          .read<FavoritePokemonViewModel>()
                          .add(OnLoadFavoritePokemon());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
