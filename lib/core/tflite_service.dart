import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter interpreter;

  /// Load TensorFlow Lite model from assets
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/models/best_float32.tflite');
      debugPrint("TFLite model loaded!");
    } catch (e) {
      debugPrint("Error loading model: $e");
    }
  }

  /// Check model input shape
  void checkModelInputShape() {
    try {
      final inputShape = interpreter.getInputTensor(0).shape;
      debugPrint("Model Input Shape: $inputShape");
    } catch (e) {
      debugPrint("Error checking input shape: $e");
    }
  }

  /// Check model output shape
  void checkModelOutputShape() {
    try {
      final outputShape = interpreter.getOutputTensor(0).shape;
      debugPrint("Model Output Shape: $outputShape");
    } catch (e) {
      debugPrint("Error checking output shape: $e");
    }
  }

  /// Run inference and return detected feces count
  Future<Map<String, int>> predict(File imageFile) async {
    try {
      var input = await _preprocessImage(imageFile);
      var output = List.generate(1, (_) => List.generate(12, (_) => List.filled(8400, 0.0)));

      interpreter.run(input, output);
      return _parseModelOutput(output);
    } catch (e) {
      debugPrint("Error during prediction: $e");
      return _getEmptyPrediction();
    }
  }

  /// Preprocess the image: resize, normalize, and convert to tensor
  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    try {
      img.Image image = img.decodeImage(await imageFile.readAsBytes())!;
      img.Image resizedImage = img.copyResize(image, width: 640, height: 640);

      List<List<List<double>>> imageTensor = List.generate(
        640,
        (y) => List.generate(
          640,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [pixel.r.toDouble() / 255.0, pixel.g.toDouble() / 255.0, pixel.b.toDouble() / 255.0];
          },
        ),
      );

      return [imageTensor];
    } catch (e) {
      debugPrint("Error during image preprocessing: $e");
      return [
        [
          [[]]
        ]
      ]; // Return an empty structure
    }
  }

  /// Parse model output into a human-readable format
  Map<String, int> _parseModelOutput(List<List<List<double>>> output) {
    Map<String, int> fecesCount = _getEmptyPrediction();

    try {
      for (int i = 0; i < 8400; i++) {
        double confidence = output[0][4][i]; // Confidence score
        if (confidence > 0.3) {
          // Only count detections above confidence threshold
          int classIndex = _getMaxClassIndex(output[0], i);
          if (classIndex >= 0 && classIndex < labels.length) {
            fecesCount[labels[classIndex]] = (fecesCount[labels[classIndex]] ?? 0) + 1;
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing model output: $e");
    }

    return fecesCount;
  }

  /// Get the class index with the highest confidence
  int _getMaxClassIndex(List<List<double>> output, int index) {
    double maxVal = -double.infinity;
    int maxIndex = -1;
    try {
      for (int j = 5; j < 12; j++) {
        if (output[j][index] > maxVal) {
          maxVal = output[j][index];
          maxIndex = j - 5; // Adjust index to match label list
        }
      }
    } catch (e) {
      debugPrint("Error finding max class index: $e");
    }
    return maxIndex;
  }

  /// Labels corresponding to model output
  final List<String> labels = [
    "Normal",
    "Cecotroph",
    "Small Misshapen",
    "Large Fecal Pellets",
    "String of Pearls",
    "Mucus On",
    "Diarrhea",
    "Bloody Stool",
  ];

  /// Return an empty map for error handling
  Map<String, int> _getEmptyPrediction() {
    return {
      "Normal": 0,
      "Cecotroph": 0,
      "Small Misshapen": 0,
      "Large Fecal Pellets": 0,
      "String of Pearls": 0,
      "Mucus On": 0,
      "Diarrhea": 0,
      "Bloody Stool": 0,
    };
  }
}
