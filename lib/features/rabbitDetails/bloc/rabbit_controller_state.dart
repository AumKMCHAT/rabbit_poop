part of 'rabbit_controller_bloc.dart';

@immutable
sealed class RabbitControllerState {}

final class RabbitControllerInitial extends RabbitControllerState {}

final class AddRabbitResult extends RabbitControllerState {
  final bool isSuccess;

  AddRabbitResult({
    required this.isSuccess,
  }) : super();
}

final class ShowRabbitInfoAndHistoryState extends RabbitControllerState {
  final String name;
  final double weight;
  final double height;
  final int age;
  final List<HealthHistoryItem> healthHistoryItemList;
  final String? aboutRabbit;

  ShowRabbitInfoAndHistoryState({
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.healthHistoryItemList,
    this.aboutRabbit,
  }) : super();
}

final class TotalHealthRecordState extends RabbitControllerState {
  final int totalHealthRecord;

  TotalHealthRecordState({
    required this.totalHealthRecord,
  }) : super();
}

final class NavigateToRabbitDetailScreen extends RabbitControllerState {
  final int rabbitId;

  NavigateToRabbitDetailScreen({
    required this.rabbitId,
  }) : super();
}

final class NavigateToAddNewPoopEntryState extends RabbitControllerState {}

final class NavigateToHealthStatusScreenState extends RabbitControllerState {
  final int healthId;

  NavigateToHealthStatusScreenState({
    required this.healthId,
  }) : super();
}

final class NavigateToHealthStatusScreenTakePictureEventState extends RabbitControllerState {
  final int healthId;

  NavigateToHealthStatusScreenTakePictureEventState({
    required this.healthId,
  }) : super();
}

final class NavigateToAddNewFecesDayScreenState extends RabbitControllerState {
  final String date;

  NavigateToAddNewFecesDayScreenState({
    required this.date,
  }) : super();
}

final class ShowHealthStatusState extends RabbitControllerState {
  final String healthStatus;
  final int totalFeces;
  final List<FecesToday> fecesTodayList;
  final Map<String, int> fecesCount;
  final String date;

  ShowHealthStatusState({
    required this.healthStatus,
    required this.totalFeces,
    required this.fecesCount,
    required this.fecesTodayList,
    required this.date,
  }) : super();
}
