import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_vision/flutter_vision.dart';

class TFLiteService {

  final FlutterVision vision = FlutterVision();

  Future<void> loadModelFlutterVision() async {
    await vision.loadYoloModel(
      modelPath: "assets/models/best_float32.tflite",
      labels: "assets/models/labels.txt",
      modelVersion: "yolov8",
      // Specify YOLOv8
      quantization: false,
      // Since we are using float32
      numThreads: 1, // Adjust based on performance needs
    );
  }

  Future<Map<String, int>> runYOLOv8(Uint8List imageBytes) async {
    try {
      final List<Map<String, dynamic>> results = await vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: 640, // Adjust based on model
        imageWidth: 640, // Adjust based on model
        iouThreshold: 0.4, // Intersection over Union threshold
        confThreshold: 0.5, // Confidence threshold
      );

      // 🛑 Exclude labels "a", "b", "c", "d"
      final ignoredLabels = {"a", "b", "c", "d"};

      // ✅ Process results: Count detections per label
      Map<String, int> fecesCount = {};
      for (var detection in results) {
        String label = detection['tag'];
        if (!ignoredLabels.contains(label)) {
          fecesCount[label] = (fecesCount[label] ?? 0) + 1;
        }
      }

      log("🟢 Raw Processed YOLO Results: $results");
      log("🟢 Processed YOLO Results: $fecesCount");
      return fecesCount;
    } catch (e) {
      log("🚨 Error in YOLO Detection: $e");
      return {}; // Return an empty map on error
    }
  }
}
