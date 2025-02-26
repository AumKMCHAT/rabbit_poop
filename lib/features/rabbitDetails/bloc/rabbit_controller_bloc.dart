import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_poop/core/database_helper.dart';
import 'package:rabbit_poop/core/tflite_service.dart';
import 'package:rabbit_poop/features/rabbitDetails/model/feces_today_view_model.dart';

part 'rabbit_controller_event.dart';
part 'rabbit_controller_state.dart';

class RabbitControllerBloc extends Bloc<RabbitControllerEvent, RabbitControllerState> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final TFLiteService _tfliteService = TFLiteService();

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
        fecesCount: {
          "Normal": 0,
          "Cecotroph": 0,
          "Small Misshapen": 0,
          "Large Fecal Pellets": 0,
          "String of Pearls": 0,
          "Mucus On": 0,
          "Diarrhea": 0,
          "Bloody Stool": 0,
        },
      ));
      return;
    }

    int healthStatusId = healthStatusData['id'];
    String healthStatus = healthStatusData['status'] ?? "Unknown";
    String date = healthStatusData["date"] ?? "";

    // Step 2: Fetch feces records for this health status
    final fecesRecords = await dbHelper.getFecesRecordsByHealthStatus(healthStatusId);

    // Step 3: Convert raw data into model and parse time
    Map<String, int> timeGroupedFeces = {};
    Map<String, int> fecesCount = {
      "Normal": 0,
      "Cecotroph": 0,
      "Small Misshapen": 0,
      "Large Fecal Pellets": 0,
      "String of Pearls": 0,
      "Mucus On": 0,
      "Diarrhea": 0,
      "Bloody Stool": 0,
    };

    int totalFeces = 0;

    for (var record in fecesRecords) {
      String fecesType = record['feces_type'] ?? "Unknown";
      String time = record['time'];
      int quantity = record['quantity'] ?? 1;

      // **Combine same time records** by summing up quantities
      timeGroupedFeces[time] = (timeGroupedFeces[time] ?? 0) + quantity;

      // Count feces by type
      if (fecesCount.containsKey(fecesType)) {
        fecesCount[fecesType] = (fecesCount[fecesType] ?? 0) + quantity;
      }

      // Update total feces count
      totalFeces += quantity;
    }

    // Step 4: Convert combined time map into a list
    List<FecesToday> fecesTodayList = timeGroupedFeces.entries.map((entry) {
      return FecesToday(
        time: entry.key,
        quantity: entry.value,
      );
    }).toList();

    // Step 5: Sort fecesTodayList by time
    fecesTodayList.sort((a, b) {
      DateTime timeA = _parseTime(a.time);
      DateTime timeB = _parseTime(b.time);
      return timeA.compareTo(timeB);
    });

    // Step 6: Emit state with sorted data and feces count
    emit(ShowHealthStatusState(
      healthStatus: healthStatus,
      totalFeces: totalFeces,
      fecesTodayList: fecesTodayList,
      date: date,
      fecesCount: fecesCount, // Updated feces count
    ));
  }

  Future<void> _processFetchHealthStatusRecordEvent(FetchHealthStatusRecordEvent event, emit) async {
    // Fetch all health status records for the given rabbit ID
    final healthStatusRecords = await dbHelper.getAllHealthStatusRecords(event.rabbitId);

    // Emit state with the total number of records
    emit(TotalHealthRecordState(
      totalHealthRecord: healthStatusRecords.length + 1,
    ));
  }

  Future<void> _processTakePictureEvent(TakePictureEvent event, emit) async {
    emit(RabbitControllerInitial());

    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic>? existingHealthStatus;
    int? healthId = event.healthId;

    XFile? imageFile = event.image;
    File file = File(imageFile.path);

    await _tfliteService.loadModel();
    _tfliteService.checkModelInputShape();
    _tfliteService.checkModelOutputShape();

    // Run inference and get results
    Map<String, int> prediction = await _tfliteService.predict(file);

    debugPrint("Prediction: $prediction");

    // Retrieve or create a health status entry
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
      healthStatusId = existingHealthStatus['id'];
    } else {
      healthStatusId = await dbHelper.insertHealthStatus(
        event.rabbitId,
        event.date,
        _determineHealthStatus(prediction),
        _generateRecommendation(prediction),
      );
    }

    // Step 1: Store detected feces data
    bool hasFeces = prediction.values.any((quantity) => quantity > 0);

    for (var entry in prediction.entries) {
      await dbHelper.insertFecesRecord(
        healthStatusId,
        event.time ?? DateFormat('HH:mm').format(DateTime.now()), // Use event time or fallback
        entry.value, // Quantity detected
        entry.key, // Feces type
      );
    }

    // Step 2: If no feces detected, store a default record with quantity 0
    if (!hasFeces) {
      await dbHelper.insertFecesRecord(
        healthStatusId,
        event.time ?? DateFormat('HH:mm').format(DateTime.now()), // Use event time or fallback
        0, // No feces detected
        "No Feces", // Label for no detection
      );
    }

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

  String _determineHealthStatus(Map<String, int> fecesCount) {
    if (fecesCount["Diarrhea"]! > 0 || fecesCount["Bloody Stool"]! > 0) {
      return "Unhealthy";
    }
    if (fecesCount["Small Misshapen"]! > 3 || fecesCount["Mucus On"]! > 1) {
      return "Potential Issue";
    }
    return "Normal";
  }

  String _generateRecommendation(Map<String, int> fecesCount) {
    if (fecesCount["Diarrhea"]! > 0) {
      return "Monitor rabbit for dehydration. Provide more fiber.";
    }
    if (fecesCount["Bloody Stool"]! > 0) {
      return "Seek veterinary attention immediately.";
    }
    if (fecesCount["Small Misshapen"]! > 3) {
      return "Increase hydration and check diet.";
    }
    return "No issues detected.";
  }
}
