part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class HomeFetchRabbitInfoEvent extends HomeEvent {}

final class HomeAddRabbitEvent extends HomeEvent {}

final class HomeOpenRabbitDetailEvent extends HomeEvent {
  final int rabbitId;

  HomeOpenRabbitDetailEvent({
    required this.rabbitId,
  }) : super();
}

final class HomeSearchRabbitNameEvent extends HomeEvent {
  final String query;

  HomeSearchRabbitNameEvent({required this.query});
}
