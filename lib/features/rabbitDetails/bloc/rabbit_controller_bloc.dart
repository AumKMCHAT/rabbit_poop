import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rabbit_poop/core/database_helper.dart';
import 'package:rabbit_poop/features/rabbitDetails/model/feces_today_view_model.dart';

part 'rabbit_controller_event.dart';

part 'rabbit_controller_state.dart';

class RabbitControllerBloc extends Bloc<RabbitControllerEvent, RabbitControllerState> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  RabbitControllerBloc() : super(RabbitControllerInitial()) {
    on<AddRabbitInfoEvent>(_processAddRabbitInfoEvent);
    on<EditRabbitDataEvent>(_processEditRabbitDataEvent);
    on<FetchRabbitInfoEvent>(_processFetchRabbitInfoEvent);
    on<FetchHealthStatusEvent>(_processFetchHealthStatusEvent);
    on<FetchHealthStatusRecordEvent>(_processFetchHealthStatusRecordEvent);
    on<TakePictureEvent>(_processTakePictureEvent);
    on<NavigateToAddNewPoopTodayEvent>(_processNavigateToAddNewPoopTodayEvent);
    on<NavigateToHealthStatusScreenEvent>(_processNavigateToHealthStatusScreenEvent);
    on<NavigateToAddFecesDayScreenEvent>(_processNavigateToAddFecesTodayScreenEvent);
  }

  Future<void> _processAddRabbitInfoEvent(AddRabbitInfoEvent event, emit) async {
    debugPrint("AddRabbitInfoEvent name: ${event.name}");
    debugPrint("AddRabbitInfoEvent age: ${event.age}");
    debugPrint("AddRabbitInfoEvent weight: ${event.weight}");
    debugPrint("AddRabbitInfoEvent height: ${event.height}");

    if (event.rabbitId == null) {
      // Create new record
      try {
        int newId = await dbHelper.insertRabbit({
          'name': event.name,
          'age': event.age,
          'weight': event.weight,
          'height': event.height,
          'about': event.about,
          'created_at': DateTime.now().toIso8601String(),
        });

        debugPrint("New rabbit created with ID: $newId");

        // Emit success state and navigate to detail screen
        emit(AddRabbitResult(isSuccess: true));
        await Future.delayed(const Duration(milliseconds: 300));
        emit(NavigateToRabbitDetailScreen(rabbitId: newId));
      } catch (error) {
        debugPrint("insertRabbit error $error");
        emit(AddRabbitResult(isSuccess: false));
      }
    } else {
      try {
        // Update existing rabbit record
        int updatedRows = await dbHelper.updateRabbit(event.rabbitId!, {
          'name': event.name,
          'age': event.age,
          'weight': event.weight,
          'height': event.height,
          'about': event.about,
        });

        debugPrint("Rabbit with ID ${event.rabbitId} updated: $updatedRows rows affected");

        emit(AddRabbitResult(isSuccess: true));
        await Future.delayed(const Duration(milliseconds: 300));
        emit(NavigateToRabbitDetailScreen(rabbitId: event.rabbitId!));
      } catch (error) {
        emit(AddRabbitResult(isSuccess: false));
      }
    }
  }

  Future<void> _processEditRabbitDataEvent(EditRabbitDataEvent event, emit) async {
    emit(NavigateToRabbitDetailScreen(rabbitId: event.id));
  }

  Future<void> _processFetchRabbitInfoEvent(FetchRabbitInfoEvent event, emit) async {
    // Fetch Rabbit Details
    final rabbitData = await dbHelper.getRabbitById(event.rabbitId);

    if (rabbitData == null) {
      emit(ShowRabbitInfoAndHistoryState(
        name: "Unknown",
        weight: 0.0,
        height: 0.0,
        age: 0,
        aboutRabbit: "No data available",
        healthHistoryItemList: [],
      ));
      return;
    }

    // Fetch Health History
    final healthHistory = await dbHelper.getHealthHistory(event.rabbitId);
    final List<HealthHistoryItem> historyList = healthHistory.map((record) {
      return HealthHistoryItem(
        healthId: record["id"], // Health Status ID for querying feces records
        date: record["date"].toString(),
      );
    }).toList();

    // Emit State with DB Data
    emit(ShowRabbitInfoAndHistoryState(
      name: rabbitData["name"],
      weight: rabbitData["weight"],
      height: rabbitData["height"],
      age: rabbitData["age"],
      aboutRabbit: rabbitData["about"] ?? "No details available",
      healthHistoryItemList: historyList,
    ));
  }

  Future<void> _processNavigateToAddNewPoopTodayEvent(NavigateToAddNewPoopTodayEvent event, emit) async {
    emit(NavigateToAddNewPoopEntryState());
  }

  Future<void> _processNavigateToHealthStatusScreenEvent(NavigateToHealthStatusScreenEvent event, emit) async {
    emit(NavigateToHealthStatusScreenState(healthId: event.healthId));
  }

  Future<void> _processFetchHealthStatusEvent(FetchHealthStatusEvent event, emit) async {
    final dbHelper = DatabaseHelper.instance;

    // Step 1: Fetch latest health status for the rabbit
    final healthStatusData = await dbHelper.getHealthStatusById(event.healthId);

    if (healthStatusData == null) {
      emit(ShowHealthStatusState(
        healthStatus: "No data",
        totalFeces: 0,
        fecesTodayList: [],
        date: "",
      ));
      return;
    }

    int healthStatusId = healthStatusData['id'];
    String healthStatus = healthStatusData['status'] ?? "Unknown";
    String date = healthStatusData["date"] ?? "";

    // Step 2: Fetch feces records for this health status
    final fecesRecords = await dbHelper.getFecesRecordsByHealthStatus(healthStatusId);

    // Step 3: Convert raw data into model and parse time
    List<FecesToday> fecesTodayList = fecesRecords.map((record) {
      return FecesToday(
        time: record['time'],
        quantity: record['quantity'],
      );
    }).toList();

    // Step 4: Sort fecesTodayList by time
    fecesTodayList.sort((a, b) {
      DateTime timeA = _parseTime(a.time);
      DateTime timeB = _parseTime(b.time);
      return timeA.compareTo(timeB);
    });

    // Step 5: Emit state with sorted data
    emit(ShowHealthStatusState(
      healthStatus: healthStatus,
      totalFeces: fecesTodayList.length,
      fecesTodayList: fecesTodayList,
      date: date,
    ));
  }

  Future<void> _processFetchHealthStatusRecordEvent(FetchHealthStatusRecordEvent event, emit) async {
    // Fetch all health status records for the given rabbit ID
    final healthStatusRecords = await dbHelper.getAllHealthStatusRecords(event.rabbitId);

    // Emit state with the total number of records
    emit(TotalHealthRecordState(
      totalHealthRecord: healthStatusRecords.length+1,
    ));
  }

  Future<void> _processTakePictureEvent(TakePictureEvent event, emit) async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic>? existingHealthStatus;
    int? healthId = event.healthId;

    if (healthId != null) {
      existingHealthStatus = await dbHelper.getHealthStatusByIdAndDate(
        healthId,
        event.date,
      );
    } else {
      existingHealthStatus = await dbHelper.getHealthStatusByRabbitIdAndDate(
        event.rabbitId,
        event.date,
      );
    }

    int healthStatusId;

    if (existingHealthStatus != null) {
      // Health status already exists, use the existing ID
      healthStatusId = existingHealthStatus['id'];
    } else {
      // Insert new health status since it does not exist
      healthStatusId = await dbHelper.insertHealthStatus(
        event.rabbitId,
        event.date,
        "Normal", // Mock data for health status
        "No issues detected", // Mock data for recommendation
      );
    }

    // Step 2: Insert Feces Record linked to the healthStatusId
    int fecesRecordId = await dbHelper.insertFecesRecord(
      healthStatusId,
      event.time ?? DateFormat('HH:mm').format(DateTime.now()), // Get only time
      1, // Mock quantity
    );

    // Navigate to Health Status Screen
    emit(NavigateToHealthStatusScreenTakePictureEventState(healthId: healthStatusId));
  }

  Future<void> _processNavigateToAddFecesTodayScreenEvent(NavigateToAddFecesDayScreenEvent event, emit) async {
    emit(NavigateToAddNewFecesDayScreenState(date: event.date));
  }

  // ✅ Function to Parse Time String into DateTime
  DateTime _parseTime(String timeString) {
    try {
      // If time is already formatted correctly (HH:mm), parse it
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(timeString)) {
        return DateFormat('HH:mm').parse(timeString);
      }
      // If time contains full ISO format, parse it
      return DateTime.parse(timeString);
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return DateTime(2000, 1, 1); // Return a default time to avoid crashes
    }
  }
}
