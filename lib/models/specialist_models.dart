/// Data model for a demo eye specialist doctor.
/// All fields are clearly marked DEMO. In production, replace with 
/// data from a verified healthcare provider API.
class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String qualifications;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double consultationFee;
  final String clinic;
  final String address;
  final String distance;
  final bool isVerified;
  final bool offersOnlineConsultation;
  final bool isAvailableToday;
  final bool isFemale;
  final String avatarInitials;
  final List<String> availableDays;
  final List<String> availableSlots;

  final String phone;
  final String email;
  final double latitude;
  final double longitude;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualifications,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.consultationFee,
    required this.clinic,
    required this.address,
    required this.distance,
    required this.isVerified,
    required this.offersOnlineConsultation,
    required this.isAvailableToday,
    required this.isFemale,
    required this.avatarInitials,
    required this.availableDays,
    required this.availableSlots,
    this.phone = '+923001234567',
    this.email = 'contact@clinic.com',
    this.latitude = 31.5204,
    this.longitude = 74.3587,
  });
}

/// Data model for a booked appointment.
class AppointmentModel {
  final String id;
  final DoctorModel doctor;
  final DateTime dateTime;
  final String consultationType; // 'Clinic Visit' | 'Online Consultation'
  final String status; // 'upcoming' | 'completed' | 'cancelled'

  const AppointmentModel({
    required this.id,
    required this.doctor,
    required this.dateTime,
    required this.consultationType,
    required this.status,
  });

  AppointmentModel copyWith({DateTime? dateTime, String? status, String? consultationType, DoctorModel? doctor}) {
    return AppointmentModel(
      id: id,
      doctor: doctor ?? this.doctor,
      dateTime: dateTime ?? this.dateTime,
      consultationType: consultationType ?? this.consultationType,
      status: status ?? this.status,
    );
  }
}

/// DEMO doctor data. In production, replace with verified API data.
class DemoSpecialistData {
  static const List<DoctorModel> allDoctors = [
    DoctorModel(
      id: 'd1',
      name: 'Dr. Aisha Rahman',
      specialty: 'Glaucoma & Ophthalmology',
      qualifications: 'MBBS, FRCS (Ophthalmology)',
      rating: 4.9,
      reviewCount: 312,
      experienceYears: 14,
      consultationFee: 2500,
      clinic: 'Vision Care Centre',
      address: 'Block 4, Clifton, Karachi',
      distance: '1.2 km',
      isVerified: true,
      offersOnlineConsultation: true,
      isAvailableToday: true,
      isFemale: true,
      avatarInitials: 'AR',
      availableDays: ['Mon', 'Tue', 'Thu', 'Sat'],
      availableSlots: ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'],
    ),
    DoctorModel(
      id: 'd2',
      name: 'Dr. Tariq Mahmood',
      specialty: 'Retina & Ophthalmology',
      qualifications: 'MBBS, MS (Ophthalmology), FCPS',
      rating: 4.7,
      reviewCount: 184,
      experienceYears: 20,
      consultationFee: 3000,
      clinic: 'National Eye Hospital',
      address: 'Main Boulevard, Gulberg, Lahore',
      distance: '3.4 km',
      isVerified: true,
      offersOnlineConsultation: false,
      isAvailableToday: false,
      isFemale: false,
      avatarInitials: 'TM',
      availableDays: ['Mon', 'Wed', 'Fri'],
      availableSlots: ['10:00 AM', '11:00 AM', '12:00 PM', '05:00 PM', '06:00 PM'],
    ),
    DoctorModel(
      id: 'd3',
      name: 'Dr. Sarah Ali',
      specialty: 'Cataract & Refractive Surgery',
      qualifications: 'MBBS, DO (Ophthalmology)',
      rating: 4.8,
      reviewCount: 267,
      experienceYears: 11,
      consultationFee: 2000,
      clinic: 'Clear Vision Clinic',
      address: 'F-7 Markaz, Islamabad',
      distance: '0.8 km',
      isVerified: true,
      offersOnlineConsultation: true,
      isAvailableToday: true,
      isFemale: true,
      avatarInitials: 'SA',
      availableDays: ['Tue', 'Wed', 'Thu', 'Sat', 'Sun'],
      availableSlots: ['09:00 AM', '11:00 AM', '01:00 PM', '03:00 PM', '05:00 PM'],
    ),
    DoctorModel(
      id: 'd4',
      name: 'Dr. Fawad Khan',
      specialty: 'Comprehensive Ophthalmology',
      qualifications: 'MBBS, FCPS (Eye), Fellow AAO',
      rating: 4.6,
      reviewCount: 421,
      experienceYears: 18,
      consultationFee: 1800,
      clinic: 'Al-Shifa Eye Trust',
      address: 'Satellite Town, Rawalpindi',
      distance: '5.1 km',
      isVerified: true,
      offersOnlineConsultation: true,
      isAvailableToday: true,
      isFemale: false,
      avatarInitials: 'FK',
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      availableSlots: ['08:00 AM', '09:00 AM', '10:00 AM', '02:00 PM', '04:00 PM'],
    ),
    DoctorModel(
      id: 'd5',
      name: 'Dr. Nadia Hussain',
      specialty: 'Cornea & External Disease',
      qualifications: 'MBBS, MS (Ophthalmology)',
      rating: 4.5,
      reviewCount: 98,
      experienceYears: 8,
      consultationFee: 1500,
      clinic: 'Cornea Eye Clinic',
      address: 'DHA Phase 6, Karachi',
      distance: '2.7 km',
      isVerified: true,
      offersOnlineConsultation: true,
      isAvailableToday: false,
      isFemale: true,
      avatarInitials: 'NH',
      availableDays: ['Mon', 'Thu', 'Sat'],
      availableSlots: ['10:00 AM', '12:00 PM', '03:00 PM'],
    ),
  ];
}
