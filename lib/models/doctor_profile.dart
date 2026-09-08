import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfile {
  final String uid;
  final String name;
  final String email;
  final String specialization;
  final String qualification;
  final String licenseNumber;
  final String clinicName;
  final String clinicLocation;
  final double consultationFee;
  final String? profileImageUrl;
  final bool isAvailable;
  final String bio;
  final int experienceYears;
  final String role;
  final DateTime? createdAt;
  final List<String> availableDays;
  final List<String> availableSlots;
  final bool offersOnlineConsultation;

  DoctorProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.specialization,
    required this.qualification,
    required this.licenseNumber,
    required this.clinicName,
    required this.clinicLocation,
    required this.consultationFee,
    this.profileImageUrl,
    this.isAvailable = true,
    this.bio = '',
    this.experienceYears = 0,
    this.role = 'doctor',
    this.createdAt,
    this.availableDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.availableSlots = const ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM'],
    this.offersOnlineConsultation = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'qualification': qualification,
      'licenseNumber': licenseNumber,
      'clinicName': clinicName,
      'clinicLocation': clinicLocation,
      'consultationFee': consultationFee,
      'profileImageUrl': profileImageUrl,
      'isAvailable': isAvailable,
      'bio': bio,
      'experienceYears': experienceYears,
      'role': role,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'availableDays': availableDays,
      'availableSlots': availableSlots,
      'offersOnlineConsultation': offersOnlineConsultation,
    };
  }

  factory DoctorProfile.fromMap(Map<String, dynamic> map, String uid) {
    return DoctorProfile(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      specialization: map['specialization'] ?? '',
      qualification: map['qualification'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      clinicName: map['clinicName'] ?? '',
      clinicLocation: map['clinicLocation'] ?? '',
      consultationFee: (map['consultationFee'] as num?)?.toDouble() ?? 0.0,
      profileImageUrl: map['profileImageUrl'],
      isAvailable: map['isAvailable'] ?? true,
      bio: map['bio'] ?? '',
      experienceYears: map['experienceYears'] ?? 0,
      role: map['role'] ?? 'doctor',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      availableDays: List<String>.from(map['availableDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      availableSlots: List<String>.from(map['availableSlots'] ?? []),
      offersOnlineConsultation: map['offersOnlineConsultation'] ?? true,
    );
  }

  DoctorProfile copyWith({
    String? name,
    String? email,
    String? specialization,
    String? qualification,
    String? licenseNumber,
    String? clinicName,
    String? clinicLocation,
    double? consultationFee,
    String? profileImageUrl,
    bool? isAvailable,
    String? bio,
    int? experienceYears,
    List<String>? availableDays,
    List<String>? availableSlots,
    bool? offersOnlineConsultation,
  }) {
    return DoctorProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      clinicName: clinicName ?? this.clinicName,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      consultationFee: consultationFee ?? this.consultationFee,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
      role: role,
      createdAt: createdAt,
      availableDays: availableDays ?? this.availableDays,
      availableSlots: availableSlots ?? this.availableSlots,
      offersOnlineConsultation: offersOnlineConsultation ?? this.offersOnlineConsultation,
    );
  }
}
