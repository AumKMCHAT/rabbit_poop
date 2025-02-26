import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  late Interpreter interpreter;

  final List<String> labels = [
    "Normal",
    "Cecotroph",
    "Small Misshapen",
    "Large Fecal Pellets",
    "String of Pearls",
    "Mucus On",
    "Diarrhea",
    "Bloody Stool"
  ];

  Future<void> loadModel() async {
    // Load model from assets
    interpreter = await Interpreter.fromAsset('assets/models/best_float32.tflite');
    print("TFLite model loaded!");
  }

  void checkModelInputShape() async {
    final inputShape = interpreter.getInputTensor(0).shape;
    print("Model Input Shape: $inputShape");
  }


  void checkModelOutputShape() {
    print("Model Output Shape: ${interpreter.getOutputTensor(0).shape}");
  }

  Future<List<dynamic>> predict(File imageFile) async {
    // Convert image to tensor format
    var input = await _preprocessImage(imageFile);

    // Create output buffer dynamically to match [1, 12, 8400]
    var output = List.filled(12 * 8400, 0).reshape([1, 12, 8400]);

    // Run inference
    interpreter.run(input, output);

    print("Output: $output");

    return output;
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    // Load image and resize to 640x640
    img.Image image = img.decodeImage(await imageFile.readAsBytes())!;
    img.Image resizedImage = img.copyResize(image, width: 640, height: 640);

    // Normalize pixel values and convert them to double
    List<List<List<double>>> imageTensor = List.generate(
      640,
      (y) => List.generate(
        640,
        (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.r.toDouble() / 255.0, // Red channel
            pixel.g.toDouble() / 255.0, // Green channel
            pixel.b.toDouble() / 255.0 // Blue channel
          ];
        },
      ),
    );

    // Add batch dimension -> [1, 640, 640, 3]
    return [imageTensor];
  }

  List<Map<String, dynamic>> parseModelOutput(List<List<List<double>>> output) {
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < 8400; i++) {
      double confidence = output[0][4][i]; // Confidence score
      if (confidence > 0.3) { // Filter low-confidence detections
        int classIndex = getMaxClassIndex(output[0], i);
        results.add({
          "label": labels[classIndex],
          "confidence": confidence,
          "bbox": [
            output[0][0][i], // X
            output[0][1][i], // Y
            output[0][2][i], // Width
            output[0][3][i]  // Height
          ]
        });
      }
    }

    return results;
  }

  int getMaxClassIndex(List<List<double>> output, int index) {
    double maxVal = -double.infinity;
    int maxIndex = -1;
    for (int j = 5; j < 12; j++) {
      if (output[j][index] > maxVal) {
        maxVal = output[j][index];
        maxIndex = j - 5; // Adjust to match label index
      }
    }
    return maxIndex;
  }
}
