import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SnackbarEvent {}

final class OnSnackbarMessage extends SnackbarEvent {
  final String message;

  OnSnackbarMessage({required this.message});
}

final class SnackbarViewModel extends Bloc<SnackbarEvent, void> {
  final _controller = StreamController<String>.broadcast();

  SnackbarViewModel() : super(null) {
    on<OnSnackbarMessage>((evt, _) {
      _controller.add(evt.message);
    });
  }

  Stream<String> get messages => _controller.stream;

  void dispose() => _controller.close();
}
