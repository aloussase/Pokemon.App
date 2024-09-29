import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodel/register_view_model.dart';
import '../viewmodel/snackbar_view_model.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final NavigatorState navigator;

  const RegisterPage({required this.navigator, super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final StreamSubscription _snackbarSubscription;
  late final StreamSubscription _errorsSubscription;

  @override
  void initState() {
    super.initState();

    _snackbarSubscription = context.read<SnackbarViewModel>().messages.listen(
      (message) {
        final snackbar = SnackBar(content: Text(message));
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(snackbar);
      },
    );

    _errorsSubscription = context.read<RegisterViewModel>().errors.listen(
      (error) {
        context
            .read<SnackbarViewModel>()
            .add(OnSnackbarMessage(message: error));
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
          child: Column(
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
                  "Regístrate",
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
                      .read<RegisterViewModel>()
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
                      .read<RegisterViewModel>()
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
                  context.read<RegisterViewModel>().add(OnRegister());
                },
                child: const Text("Regístrate"),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta?"),
                  TextButton(
                    onPressed: () {
                      widget.navigator.push(
                        MaterialPageRoute(
                          builder: (_) =>
                              LoginPage(navigator: widget.navigator),
                        ),
                      );
                    },
                    child: const Text("Inicia sesión"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
