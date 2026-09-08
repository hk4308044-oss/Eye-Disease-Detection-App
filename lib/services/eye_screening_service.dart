import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/eye_screening_result.dart';

class EyeScreeningService {
  static final EyeScreeningService _instance = EyeScreeningService._internal();
  factory EyeScreeningService() => _instance;
  EyeScreeningService._internal();

  /// Simulates an AI screening process
  Future<EyeScreeningResult> analyzeEyeImage({
    required String imagePath,
    required String category,
  }) async {
    // Simulate network latency / processing time
    await Future.delayed(const Duration(seconds: 3));

    final random = Random();
    final isHealthy = random.nextDouble() > 0.3; // 70% chance of healthy for mock
    
    RiskLevel riskLevel;
    String observation;
    String explanation;
    double confidence = 85.0 + random.nextDouble() * 14.0; // 85% to 99%

    if (isHealthy) {
      riskLevel = RiskLevel.low;
      observation = "No significant abnormalities detected";
      explanation = "The AI model did not detect visual patterns associated with common eye diseases in this image. Continue with your regular routine eye check-ups.";
    } else {
      final isHighRisk = random.nextDouble() > 0.6;
      if (isHighRisk) {
        riskLevel = RiskLevel.high;
        observation = "Potential severe abnormality detected";
        explanation = "The AI detected patterns that require immediate attention from a specialist. Please consult an ophthalmologist as soon as possible.";
      } else {
        riskLevel = RiskLevel.attention;
        observation = "Minor irregularities observed";
        explanation = "Some minor irregularities were detected. It is recommended to schedule a non-urgent consultation with an eye care professional.";
      }
    }

    return EyeScreeningResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      category: category,
      observation: observation,
      riskLevel: riskLevel,
      confidence: confidence,
      explanation: explanation,
    );
  }
}
