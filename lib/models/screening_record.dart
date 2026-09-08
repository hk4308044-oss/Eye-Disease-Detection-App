import 'pre_screening_assessment.dart';

enum ConfidenceLevel { high, moderate, low }

class ScreeningRecord {
  final String id;
  final DateTime date;
  final String? imageUrl;
  final String condition;
  final ConfidenceLevel confidenceLevel;
  final int confidenceScore; // e.g. 92 for 92%
  final String explanation;
  final String recommendation;
  final PreScreeningAssessment assessmentContext;
  final String modelVersion;

  ScreeningRecord({
    required this.id,
    required this.date,
    this.imageUrl,
    required this.condition,
    required this.confidenceLevel,
    required this.confidenceScore,
    required this.explanation,
    required this.recommendation,
    required this.assessmentContext,
    required this.modelVersion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'condition': condition,
      'confidenceLevel': confidenceLevel.name,
      'confidenceScore': confidenceScore,
      'explanation': explanation,
      'recommendation': recommendation,
      'assessmentContext': assessmentContext.toMap(),
      'modelVersion': modelVersion,
    };
  }

  factory ScreeningRecord.fromMap(Map<String, dynamic> map, String id) {
    return ScreeningRecord(
      id: id,
      date: DateTime.parse(map['date']),
      imageUrl: map['imageUrl'],
      condition: map['condition'],
      confidenceLevel: ConfidenceLevel.values.firstWhere((e) => e.name == map['confidenceLevel']),
      confidenceScore: map['confidenceScore'],
      explanation: map['explanation'],
      recommendation: map['recommendation'],
      assessmentContext: PreScreeningAssessment.fromMap(map['assessmentContext']),
      modelVersion: map['modelVersion'],
    );
  }
}
