import 'package:flutter/material.dart';

import '../pages/favorite_pokemon_page.dart';
import '../pages/home_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        if (index == 0) {
          Navigator.of(context).push(
            HomePage.route(),
          );
        }

        if (index == 1) {
          Navigator.of(context).push(
            FavoritePokemonPage.route(),
          );
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.star), label: 'Favoritos'),
      ],
    );
  }
}
