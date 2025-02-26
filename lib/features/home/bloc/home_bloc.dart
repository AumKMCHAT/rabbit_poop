import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rabbit_poop/core/database_helper.dart';
import 'package:rabbit_poop/features/home/model/rabbit_info.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<RabbitInfoHomeScreenModel> allRabbits = []; // Store original list

  HomeBloc() : super(HomeInitial()) {
    on<HomeFetchRabbitInfoEvent>(_processHomeFetchRabbitInfoEvent);
    on<HomeAddRabbitEvent>(_processHomeAddRabbitEvent);
    on<HomeOpenRabbitDetailEvent>(_processHomeOpenRabbitDetailEvent);
    on<HomeSearchRabbitNameEvent>(_processHomeSearchRabbitNameEvent);
  }

  // ✅ Fetch All Rabbits and Cache them
  Future<void> _processHomeFetchRabbitInfoEvent(HomeFetchRabbitInfoEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    final List<Map<String, dynamic>> dbRabbits = await dbHelper.getAllRabbits();
    allRabbits = dbRabbits.map((e) {
      return RabbitInfoHomeScreenModel(
        name: e['name'],
        age: e['age'],
        rabbitId: e['id'],
      );
    }).toList();

    emit(HomeShowRabbitListState(rabbitInfos: allRabbits));
  }

  Future<void> _processHomeAddRabbitEvent(HomeAddRabbitEvent event, Emitter<HomeState> emit) async {
    emit(HomeNavigateToAddRabbitScreenState());
  }

  Future<void> _processHomeOpenRabbitDetailEvent(HomeOpenRabbitDetailEvent event, Emitter<HomeState> emit) async {
    emit(HomeNavigateToOpenRabbitDetailScreenState(rabbitId: event.rabbitId));
  }

  // ✅ Search Logic: Filter Cached Rabbits
  Future<void> _processHomeSearchRabbitNameEvent(HomeSearchRabbitNameEvent event, Emitter<HomeState> emit) async {
    if (event.query.isEmpty) {
      emit(HomeShowRabbitListState(rabbitInfos: allRabbits));
      return;
    }

    final filteredRabbits =
        allRabbits.where((rabbit) => rabbit.name.toLowerCase().contains(event.query.toLowerCase())).toList();

    emit(HomeShowRabbitListState(rabbitInfos: filteredRabbits));
  }
}
