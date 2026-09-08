class PreScreeningAssessment {
  String? fullName;
  String? age; // Using String for flexibility (e.g. "22" or "12/05/1996")
  String? gender; // Optional
  
  bool hasPreviousCondition;
  List<String> previousEyeConditions;
  String? otherPreviousEyeCondition;

  bool hasPreviousSurgeries;
  String? previousEyeSurgeries;

  List<String> medicalHistory;
  String? otherMedicalHistory;

  bool hasHypertension;
  String? currentMedications;

  List<String> currentSymptoms;
  String? otherCurrentSymptoms;

  String? screeningReason;
  String? otherScreeningReason;

  DateTime? timestamp;

  PreScreeningAssessment({
    this.fullName,
    this.age,
    this.gender,
    this.hasPreviousCondition = false,
    this.previousEyeConditions = const [],
    this.otherPreviousEyeCondition,
    this.hasPreviousSurgeries = false,
    this.previousEyeSurgeries,
    this.medicalHistory = const [],
    this.otherMedicalHistory,
    this.hasHypertension = false,
    this.currentMedications,
    this.currentSymptoms = const [],
    this.otherCurrentSymptoms,
    this.screeningReason,
    this.otherScreeningReason,
    this.timestamp,
  });

  bool get isComplete {
    return fullName != null && fullName!.isNotEmpty &&
           age != null && age!.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'hasPreviousCondition': hasPreviousCondition,
      'previousEyeConditions': previousEyeConditions,
      'otherPreviousEyeCondition': otherPreviousEyeCondition,
      'hasPreviousSurgeries': hasPreviousSurgeries,
      'previousEyeSurgeries': previousEyeSurgeries,
      'medicalHistory': medicalHistory,
      'otherMedicalHistory': otherMedicalHistory,
      'hasHypertension': hasHypertension,
      'currentMedications': currentMedications,
      'currentSymptoms': currentSymptoms,
      'otherCurrentSymptoms': otherCurrentSymptoms,
      'screeningReason': screeningReason,
      'otherScreeningReason': otherScreeningReason,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  factory PreScreeningAssessment.fromMap(Map<String, dynamic> map) {
    return PreScreeningAssessment(
      fullName: map['fullName'],
      age: map['age'],
      gender: map['gender'],
      hasPreviousCondition: map['hasPreviousCondition'] ?? false,
      previousEyeConditions: List<String>.from(map['previousEyeConditions'] ?? []),
      otherPreviousEyeCondition: map['otherPreviousEyeCondition'],
      hasPreviousSurgeries: map['hasPreviousSurgeries'] ?? false,
      previousEyeSurgeries: map['previousEyeSurgeries'],
      medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
      otherMedicalHistory: map['otherMedicalHistory'],
      hasHypertension: map['hasHypertension'] ?? false,
      currentMedications: map['currentMedications'],
      currentSymptoms: List<String>.from(map['currentSymptoms'] ?? []),
      otherCurrentSymptoms: map['otherCurrentSymptoms'],
      screeningReason: map['screeningReason'],
      otherScreeningReason: map['otherScreeningReason'],
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp']) : null,
    );
  }
}
