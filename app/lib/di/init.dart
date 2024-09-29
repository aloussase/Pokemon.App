import 'package:get_it/get_it.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

import '../data/repository/auth_repository_impl.dart';
import '../data/repository/pokemon_repository_impl.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/repository/pokemon_repository.dart';
import '../domain/use_case/get_pokemon_details_use_case.dart';
import '../domain/use_case/get_pokemon_use_case.dart';
import '../domain/use_case/login_use_case.dart';
import '../domain/use_case/register_use_case.dart';
import '../ui/viewmodel/auth_view_model.dart';
import '../ui/viewmodel/home_view_model.dart';
import '../ui/viewmodel/login_view_model.dart';
import '../ui/viewmodel/pokemon_details_view_model.dart';
import '../ui/viewmodel/register_view_model.dart';
import '../ui/viewmodel/snackbar_view_model.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<Client>(http.Client());

  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(httpClient: getIt()),
  );

  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt()));
  getIt.registerSingleton<LoginViewModel>(LoginViewModel(getIt()));

  getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(getIt()));
  getIt.registerSingleton<RegisterViewModel>(RegisterViewModel(getIt()));

  getIt.registerSingleton<SnackbarViewModel>(SnackbarViewModel());

  getIt.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(authRepository: getIt()),
  );

  getIt.registerSingleton<PokemonRepository>(PokemonRepositoryImpl(getIt()));
  getIt.registerSingleton(GetPokemonUseCase(getIt()));
  getIt.registerFactory(() => HomeViewModel(getIt(), getIt()));

  getIt.registerSingleton(GetPokemonDetailsUseCase(getIt()));
  getIt.registerFactory(() => PokemonDetailsViewModel(getIt()));
}
