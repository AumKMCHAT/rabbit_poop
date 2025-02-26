import 'package:get_it/get_it.dart';
import 'package:rabbit_poop/features/home/bloc/home_bloc.dart';
import 'package:rabbit_poop/features/rabbitDetails/bloc/rabbit_controller_bloc.dart';

final GetIt getIt = GetIt.instance;

void setupDI() {
  // Repositories
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  // getIt.registerLazySingleton<HabitRepository>(() => HabitRepository());

  // ViewModels (Cubits)
  getIt.registerFactory<HomeBloc>(() => HomeBloc());
  getIt.registerFactory<RabbitControllerBloc>(() => RabbitControllerBloc());
}
