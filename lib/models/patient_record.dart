import 'eye_screening_result.dart';

/// Lightweight patient record read by a doctor.
/// Composed from users/{uid} profile + users/{uid}/screenings sub-collection.
class PatientRecord {
  final String uid;
  final String name;
  final int age;
  final String gender;
  final String? profileImageUrl;
  final List<String> symptoms;
  final List<String> eyeConditions;
  final bool wearsGlasses;
  final bool familyHistory;
  final List<EyeScreeningResult> screenings;
  final String? lastAppointmentDate;

  PatientRecord({
    required this.uid,
    required this.name,
    required this.age,
    required this.gender,
    this.profileImageUrl,
    this.symptoms = const [],
    this.eyeConditions = const [],
    this.wearsGlasses = false,
    this.familyHistory = false,
    this.screenings = const [],
    this.lastAppointmentDate,
  });

  factory PatientRecord.fromMap(
    Map<String, dynamic> map,
    String uid, {
    List<EyeScreeningResult> screenings = const [],
    String? lastAppointmentDate,
  }) {
    return PatientRecord(
      uid: uid,
      name: map['name'] ?? 'Unknown',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Unknown',
      profileImageUrl: map['profileImageUrl'],
      symptoms: List<String>.from(map['commonSymptoms'] ?? []),
      eyeConditions: List<String>.from(map['eyeConditions'] ?? []),
      wearsGlasses: map['wearsGlasses'] ?? false,
      familyHistory: map['familyHistory'] ?? false,
      screenings: screenings,
      lastAppointmentDate: lastAppointmentDate,
    );
  }

  PatientRecord copyWith({List<EyeScreeningResult>? screenings, String? lastAppointmentDate}) {
    return PatientRecord(
      uid: uid,
      name: name,
      age: age,
      gender: gender,
      profileImageUrl: profileImageUrl,
      symptoms: symptoms,
      eyeConditions: eyeConditions,
      wearsGlasses: wearsGlasses,
      familyHistory: familyHistory,
      screenings: screenings ?? this.screenings,
      lastAppointmentDate: lastAppointmentDate ?? this.lastAppointmentDate,
    );
  }
}
