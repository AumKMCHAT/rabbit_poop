part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeError extends HomeState {
  final String message;

  HomeError({
    required this.message,
  }) : super();
}

final class HomeShowRabbitListState extends HomeState {
  List<RabbitInfoHomeScreenModel> rabbitInfos;

  HomeShowRabbitListState({
    required this.rabbitInfos,
  }) : super();
}

final class HomeNavigateToAddRabbitScreenState extends HomeState {}

final class HomeNavigateToOpenRabbitDetailScreenState extends HomeState {
  final int rabbitId;

  HomeNavigateToOpenRabbitDetailScreenState({
    required this.rabbitId,
  }) : super();
}
