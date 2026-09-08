class UserProfile {
  final String id;
  final String name;
  final int age;
  final String? dateOfBirth; // ISO format string
  final String gender;
  final bool wearsGlasses;
  final bool familyHistory;
  final int averageScreenTimeHours;
  final List<String> commonSymptoms;
  final int eyeHealthScore;
  final int streakDays;
  final String role; // 'user' or 'admin'
  final String preferredLanguage; // 'en' or 'ur'
  final List<String> userGoals;
  final bool hasConsented;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    this.dateOfBirth,
    required this.gender,
    required this.wearsGlasses,
    required this.familyHistory,
    required this.averageScreenTimeHours,
    required this.commonSymptoms,
    this.eyeHealthScore = 85,
    this.streakDays = 0,
    this.role = 'user',
    this.preferredLanguage = 'en',
    this.userGoals = const [],
    this.hasConsented = false,
  });

  // Factory to create a default mocked profile for the dashboard if not set up
  factory UserProfile.defaultProfile() {
    return UserProfile(
      id: "u123",
      name: "Alex",
      age: 32,
      gender: "Male",
      wearsGlasses: true,
      familyHistory: false,
      averageScreenTimeHours: 8,
      commonSymptoms: ["Dry eyes", "Occasional blurriness"],
      eyeHealthScore: 82,
      streakDays: 3,
      role: 'user',
      preferredLanguage: 'en',
      userGoals: ["Monitor my eye-health journey"],
      hasConsented: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'wearsGlasses': wearsGlasses,
      'familyHistory': familyHistory,
      'averageScreenTimeHours': averageScreenTimeHours,
      'commonSymptoms': commonSymptoms,
      'eyeHealthScore': eyeHealthScore,
      'streakDays': streakDays,
      'role': role,
      'preferredLanguage': preferredLanguage,
      'userGoals': userGoals,
      'hasConsented': hasConsented,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    return UserProfile(
      id: documentId,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'] ?? '',
      wearsGlasses: map['wearsGlasses'] ?? false,
      familyHistory: map['familyHistory'] ?? false,
      averageScreenTimeHours: map['averageScreenTimeHours'] ?? 0,
      commonSymptoms: List<String>.from(map['commonSymptoms'] ?? []),
      eyeHealthScore: map['eyeHealthScore'] ?? 85,
      streakDays: map['streakDays'] ?? 0,
      role: map['role'] ?? 'user',
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      userGoals: List<String>.from(map['userGoals'] ?? []),
      hasConsented: map['hasConsented'] ?? false,
    );
  }
}
