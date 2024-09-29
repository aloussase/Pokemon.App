import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './di/init.dart' as di;
import './domain/repository/auth_repository.dart';
import './ui/pages/home_page.dart';
import './ui/pages/login_page.dart';
import './ui/pages/splash_page.dart';
import './ui/viewmodel/auth_view_model.dart';
import './ui/viewmodel/login_view_model.dart';
import './ui/viewmodel/register_view_model.dart';
import './ui/viewmodel/snackbar_view_model.dart';
import 'domain/repository/authentication_token_holder.dart';

void main() {
  di.setup();
  runApp(const PokemonApp());
}

class PokemonApp extends StatefulWidget {
  const PokemonApp({super.key});

  @override
  State<StatefulWidget> createState() => _PokemonAppState();
}

class _PokemonAppState extends State<PokemonApp> {
  final SnackbarViewModel _snackBarViewModel = di.getIt();
  final LoginViewModel _loginViewModel = di.getIt();

  @override
  void dispose() {
    super.dispose();
    _snackBarViewModel.dispose();
    _loginViewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SnackbarViewModel>(create: (_) => _snackBarViewModel),
        BlocProvider<LoginViewModel>(create: (_) => _loginViewModel),
        BlocProvider<AuthViewModel>(create: (_) => di.getIt()),
        BlocProvider<RegisterViewModel>(create: (_) => di.getIt()),
      ],
      child: const PokemonAppView(),
    );
  }
}

final class PokemonAppView extends StatefulWidget {
  const PokemonAppView({super.key});

  @override
  State<StatefulWidget> createState() => _PokemonAppViewState();
}

final class _PokemonAppViewState extends State<PokemonAppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AuthViewModel, AuthState>(
          listener: (context, state) {
            switch (state) {
              case Authenticated():
                AuthenticationTokenHolder.the().token = state.accessToken;
                _navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              case Unauthenticated():
                AuthenticationTokenHolder.the().token = null;
                _navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => LoginPage(navigator: _navigator),
                  ),
                  (route) => false,
                );
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const SplashPage(),
      ),
    );
  }
}
