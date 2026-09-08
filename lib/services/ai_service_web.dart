import '../models/pre_screening_assessment.dart';
import '../models/screening_record.dart';

class ModelNotLoadedException implements Exception {
  final String message;
  ModelNotLoadedException(this.message);

  @override
  String toString() => message;
}

class AIService {
  Future<void> initModel() async {}
  
  Future<bool> checkImageQuality(String imagePath) async {
    return false;
  }
  
  Future<ScreeningRecord> analyzeImage({
    required String imagePath,
    required PreScreeningAssessment assessment,
  }) async {
    throw ModelNotLoadedException("AI Image screening is not supported on the Web browser platform because TensorFlow Lite requires native bindings. Please run the app on an Android device, or Windows Desktop!");
  }
}
