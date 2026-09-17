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
  final String? profileImageUrl; // Firebase Storage download URL

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
    this.profileImageUrl,
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
      profileImageUrl: null,
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
      'profileImageUrl': profileImageUrl,
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
      profileImageUrl: map['profileImageUrl'],
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? dateOfBirth,
    String? gender,
    bool? wearsGlasses,
    bool? familyHistory,
    int? averageScreenTimeHours,
    List<String>? commonSymptoms,
    int? eyeHealthScore,
    int? streakDays,
    String? role,
    String? preferredLanguage,
    List<String>? userGoals,
    bool? hasConsented,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      wearsGlasses: wearsGlasses ?? this.wearsGlasses,
      familyHistory: familyHistory ?? this.familyHistory,
      averageScreenTimeHours: averageScreenTimeHours ?? this.averageScreenTimeHours,
      commonSymptoms: commonSymptoms ?? this.commonSymptoms,
      eyeHealthScore: eyeHealthScore ?? this.eyeHealthScore,
      streakDays: streakDays ?? this.streakDays,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      userGoals: userGoals ?? this.userGoals,
      hasConsented: hasConsented ?? this.hasConsented,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
