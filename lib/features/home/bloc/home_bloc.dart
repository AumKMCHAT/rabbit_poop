import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rabbit_poop/core/database_helper.dart';
import 'package:rabbit_poop/features/home/model/rabbit_info.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  HomeBloc() : super(HomeInitial()) {
    on<HomeFetchRabbitInfoEvent>(_processHomeFetchRabbitInfoEvent);
    on<HomeAddRabbitEvent>(_processHomeAddRabbitEvent);
    on<HomeOpenRabbitDetailEvent>(_processHomeOpenRabbitDetailEvent);
  }

  Future<void> _processHomeFetchRabbitInfoEvent(HomeFetchRabbitInfoEvent event, emit) async {
    await Future.delayed(const Duration(seconds: 1));

    // Fetch all rabbits from the database
    List<Map<String, dynamic>> dbRabbits = await dbHelper.getAllRabbits();

    // Convert database results into model list
    List<RabbitInfoHomeScreenModel> rabbitList = dbRabbits.map((e) {
      return RabbitInfoHomeScreenModel(
        name: e['name'],
        age: e['age'],
        rabbitId: e['id'], // Use the SQLite ID
      );
    }).toList();

    emit(HomeShowRabbitListState(rabbitInfos: rabbitList));
  }

  Future<void> _processHomeAddRabbitEvent(HomeAddRabbitEvent event, emit) async {
    emit(HomeNavigateToAddRabbitScreenState());
  }

  Future<void> _processHomeOpenRabbitDetailEvent(HomeOpenRabbitDetailEvent event, emit) async {
    emit(HomeNavigateToOpenRabbitDetailScreenState(rabbitId: event.rabbitId));
  }
}
