import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodel/login_view_model.dart';
import '../viewmodel/snackbar_view_model.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final NavigatorState navigator;

  const LoginPage({required this.navigator, super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final StreamSubscription _errorsSubscription;
  late final StreamSubscription<String> _snackbarSubscription;

  @override
  void initState() {
    super.initState();

    final loginViewModel = context.read<LoginViewModel>();
    final snackbarViewModel = context.read<SnackbarViewModel>();

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

    _errorsSubscription = loginViewModel.errors.listen(
      (error) {
        snackbarViewModel.add(OnSnackbarMessage(message: error));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _snackbarSubscription.cancel();
    _errorsSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: BlocBuilder<LoginViewModel, LoginState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Image(
                    image: AssetImage("assets/pokeball.png"),
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Iniciar sesión",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ingresa tu nombre de usuario",
                      labelText: "Nombre de usuario",
                    ),
                    onChanged: (value) {
                      context
                          .read<LoginViewModel>()
                          .add(OnUsernameChanged(value));
                    },
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Ingresa tu contraseña",
                      labelText: "Contraseña",
                    ),
                    onChanged: (value) {
                      context
                          .read<LoginViewModel>()
                          .add(OnPasswordChanged(value));
                    },
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () {
                      context.read<LoginViewModel>().add(OnLogin());
                    },
                    child: state.status == LoginStatus.loading
                        ? const CircularProgressIndicator()
                        : const Text("Ingresar"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta?"),
                      TextButton(
                        onPressed: () {
                          widget.navigator.push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterPage(navigator: widget.navigator),
                            ),
                          );
                        },
                        child: const Text("Regístrate"),
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
