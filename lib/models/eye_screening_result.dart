import 'package:cloud_firestore/cloud_firestore.dart';

enum RiskLevel {
  low,
  attention,
  high
}

class EyeScreeningResult {
  final String id;
  final DateTime date;
  final String category;
  final String observation;
  final RiskLevel riskLevel;
  final double confidence;
  final String explanation;
  final String modelVersion; // e.g., 'v1.2'
  final String processingStatus; // 'completed', 'failed', 'rejected'

  EyeScreeningResult({
    required this.id,
    required this.date,
    required this.category,
    required this.observation,
    required this.riskLevel,
    required this.confidence,
    required this.explanation,
    this.modelVersion = 'v1.0',
    this.processingStatus = 'completed',
  });

  factory EyeScreeningResult.fromFirestore(Map<String, dynamic> data, String documentId) {
    RiskLevel parseRiskLevel(String? level) {
      if (level == null) return RiskLevel.low;
      switch (level.toLowerCase()) {
        case 'low':
        case 'lowrisk':
          return RiskLevel.low;
        case 'attention':
        case 'moderate':
          return RiskLevel.attention;
        case 'high':
        case 'highrisk':
        case 'severe':
          return RiskLevel.high;
        default:
          return RiskLevel.low;
      }
    }

    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    double parsedConfidence = 0.0;
    if (data['confidence'] != null) {
      parsedConfidence = (data['confidence'] as num).toDouble();
    } else if (data['confidenceScore'] != null) {
      parsedConfidence = (data['confidenceScore'] as num).toDouble() / 100.0;
    }

    return EyeScreeningResult(
      id: documentId,
      date: parsedDate,
      category: data['category'] ?? 'General Screening',
      observation: data['observation'] ?? data['condition'] ?? 'Unknown',
      riskLevel: parseRiskLevel(data['riskLevel'] ?? data['confidenceLevel'] ?? 'low'),
      confidence: parsedConfidence,
      explanation: data['explanation'] ?? '',
      modelVersion: data['modelVersion'] ?? 'v1.0',
      processingStatus: data['processingStatus'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'category': category,
      'observation': observation,
      'riskLevel': riskLevel.name,
      'confidence': confidence,
      'explanation': explanation,
      'modelVersion': modelVersion,
      'processingStatus': processingStatus,
    };
  }
}
