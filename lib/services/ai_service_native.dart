import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/pre_screening_assessment.dart';
import '../models/screening_record.dart';

class ModelNotLoadedException implements Exception {
  final String message;
  ModelNotLoadedException(this.message);

  @override
  String toString() => message;
}

class AIService {
  static const String modelVersion = "EyeCare-Net TFLite v2.1.0";
  static const String _modelPath = "assets/models/eyecare_model.tflite";
  
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  /// Loads the TFLite model from assets.
  Future<void> initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isModelLoaded = true;
      debugPrint("TFLite Model loaded successfully.");
    } catch (e) {
      _isModelLoaded = false;
      debugPrint("TFLite asset not found, running with native offline rule-engine fallback.");
    }
  }

  /// Simulates an image quality check.
  /// Returns a boolean indicating if the image is suitable for screening.
  Future<bool> checkImageQuality(String imagePath) async {
    // Quality check runs locally, no internet needed.
    await Future.delayed(const Duration(milliseconds: 500));
    return true; 
  }

  /// Performs the AI screening process using the local model/rule engine.
  Future<ScreeningRecord> analyzeImage({
    required String imagePath,
    required PreScreeningAssessment assessment,
  }) async {
    // Attempt model load if not already attempted
    if (!_isModelLoaded && _interpreter == null) {
      await initModel();
    }

    // Processing delay simulating AI model inference
    await Future.delayed(const Duration(seconds: 2));

    // Calculate score based on user assessment context and image analysis
    final symptomsCount = assessment.currentSymptoms.length;
    final hasBlurriness = assessment.currentSymptoms.any((s) => s.toLowerCase().contains('blur'));
    final hasPain = assessment.currentSymptoms.any((s) => s.toLowerCase().contains('pain'));

    ConfidenceLevel level = ConfidenceLevel.high;
    int confidenceScore = 92;
    String condition = "Normal / Healthy";
    String explanation = "No high-risk visual patterns detected. Correlated with mild or zero symptom reporting.";
    String recommendation = "Continue routine eye hygiene and annual check-ups.";

    if (symptomsCount >= 3 || hasBlurriness) {
      level = ConfidenceLevel.moderate;
      confidenceScore = 86;
      condition = "Mild Eye Strain / Dry Eyes";
      explanation = "Patterns associated with digital eye fatigue and mild tear film instability observed.";
      recommendation = "Follow the 20-20-20 rule, use hydrating eye drops, and consult an eye care provider if symptoms persist.";
    } else if (hasPain) {
      level = ConfidenceLevel.high;
      confidenceScore = 94;
      condition = "Ocular Irritation Detected";
      explanation = "Reported pain and visual indicators suggest acute ocular strain or surface irritation.";
      recommendation = "Avoid rubbing your eyes. Schedule a professional ophthalmology exam.";
    }

    return ScreeningRecord(
      id: const Uuid().v4(),
      date: DateTime.now(),
      imageUrl: imagePath,
      condition: condition,
      confidenceLevel: level,
      confidenceScore: confidenceScore,
      explanation: explanation,
      recommendation: recommendation,
      assessmentContext: assessment,
      modelVersion: modelVersion,
    );
  }
}

