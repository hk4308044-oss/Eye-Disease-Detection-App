import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  static const String modelVersion = "FastAPI Backend API v1.0";

  String get _resolvedApiUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  /// Model is now hosted on the backend.
  Future<void> initModel() async {
    debugPrint("Backend API is ready to use.");
  }

  /// Simulates an image quality check.
  /// Returns a boolean indicating if the image is suitable for screening.
  Future<bool> checkImageQuality(String imagePath) async {
    // Quality check runs locally, no internet needed.
    await Future.delayed(const Duration(milliseconds: 500));
    return true; 
  }

  /// Performs the AI screening process by connecting to the FastAPI backend.
  Future<ScreeningRecord> analyzeImage({
    required String imagePath,
    required PreScreeningAssessment assessment,
  }) async {
    final uri = Uri.parse('$_resolvedApiUrl/predict');
    
    final request = http.MultipartRequest('POST', uri);
    
    // Attach the file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ),
    );

    try {
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResult = jsonDecode(responseData);
        
        final prediction = jsonResult['prediction'];
        final topClass = prediction['top_class'] as String;
        final confidenceDouble = (prediction['confidence'] as num).toDouble();
        final confidenceScore = (confidenceDouble * 100).round();
        
        ConfidenceLevel level;
        if (confidenceScore >= 90) {
          level = ConfidenceLevel.high;
        } else if (confidenceScore >= 70) {
          level = ConfidenceLevel.moderate;
        } else {
          level = ConfidenceLevel.low;
        }
        
        String explanation = "AI detected patterns consistent with $topClass.";
        String recommendation = topClass.toLowerCase().contains("normal") 
            ? "Continue routine eye hygiene and annual check-ups."
            : "Please consult an eye care provider for a professional evaluation.";
        
        return ScreeningRecord(
          id: const Uuid().v4(),
          date: DateTime.now(),
          imageUrl: imagePath,
          condition: topClass,
          confidenceLevel: level,
          confidenceScore: confidenceScore,
          explanation: explanation,
          recommendation: recommendation,
          assessmentContext: assessment,
          modelVersion: modelVersion,
        );
      } else {
        throw Exception("Server returned error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to connect to backend: $e");
    }
  }
}

