part of 'rabbit_controller_bloc.dart';

@immutable
sealed class RabbitControllerEvent {}

final class AddRabbitInfoEvent extends RabbitControllerEvent {
  final int? rabbitId;
  final String name;
  final int age;
  final double weight;
  final double height;
  final String? about;

  AddRabbitInfoEvent({
    this.rabbitId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    this.about,
  }) : super();
}

final class EditRabbitDataEvent extends RabbitControllerEvent {
  final int id;

  EditRabbitDataEvent({
    required this.id,
  }) : super();
}

final class FetchRabbitInfoEvent extends RabbitControllerEvent {
  final int rabbitId;

  FetchRabbitInfoEvent({
    required this.rabbitId,
  }) : super();
}

final class FetchHealthStatusEvent extends RabbitControllerEvent {
  final int healthId;
  final int rabbitId;

  FetchHealthStatusEvent({
    required this.healthId,
    required this.rabbitId,
  }) : super();
}

final class FetchHealthStatusRecordEvent extends RabbitControllerEvent {
  final int rabbitId;

  FetchHealthStatusRecordEvent({
    required this.rabbitId,
  }) : super();
}

final class TakePictureEvent extends RabbitControllerEvent {
  final int rabbitId;
  final int? healthId;
  final XFile image;
  final String date;
  final String? time;

  TakePictureEvent({
    this.healthId,
    required this.rabbitId,
    required this.image,
    required this.date,
    this.time,
  }) : super();
}

final class NavigateToAddNewPoopTodayEvent extends RabbitControllerEvent {}

final class NavigateToHealthStatusScreenEvent extends RabbitControllerEvent {
  final int healthId;

  NavigateToHealthStatusScreenEvent({
    required this.healthId,
  });
}

final class NavigateToAddFecesDayScreenEvent extends RabbitControllerEvent {
  final String date;

  NavigateToAddFecesDayScreenEvent({
    required this.date,
  }) : super();
}
