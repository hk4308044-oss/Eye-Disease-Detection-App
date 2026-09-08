import 'package:cloud_firestore/cloud_firestore.dart';

/// All possible appointment lifecycle statuses
enum AppointmentStatus {
  pending,
  confirmed,
  rescheduled,
  completed,
  cancelled,
  rejected;

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rejected:
        return 'Rejected';
    }
  }

  static AppointmentStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'rescheduled':
        return AppointmentStatus.rescheduled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'rejected':
        return AppointmentStatus.rejected;
      default:
        return AppointmentStatus.pending;
    }
  }
}

/// Appointment type
enum ConsultationType {
  clinic,
  online;

  String get label {
    switch (this) {
      case ConsultationType.clinic:
        return 'Clinic Visit';
      case ConsultationType.online:
        return 'Online Consultation';
    }
  }

  static ConsultationType fromString(String? s) {
    if (s?.toLowerCase() == 'online') return ConsultationType.online;
    return ConsultationType.clinic;
  }
}

/// Full appointment document stored in Firestore `appointments/{id}`
class DoctorAppointment {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String? patientImageUrl;
  final String doctorId;
  final String doctorName;
  final DateTime scheduledAt;
  final DateTime requestedAt;
  final ConsultationType consultationType;
  final AppointmentStatus status;
  final List<String> symptoms;
  final String? notes;         // doctor notes post-consultation
  final String? diagnosis;
  final String? recommendations;
  final DateTime? followUpDate;
  final String? screeningResultId; // linked AI screening
  final String? rescheduleReason;
  final DateTime? rescheduledAt;

  DoctorAppointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    this.patientImageUrl,
    required this.doctorId,
    required this.doctorName,
    required this.scheduledAt,
    required this.requestedAt,
    required this.consultationType,
    required this.status,
    this.symptoms = const [],
    this.notes,
    this.diagnosis,
    this.recommendations,
    this.followUpDate,
    this.screeningResultId,
    this.rescheduleReason,
    this.rescheduledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'patientImageUrl': patientImageUrl,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'requestedAt': Timestamp.fromDate(requestedAt),
      'consultationType': consultationType.name,
      'status': status.name,
      'symptoms': symptoms,
      'notes': notes,
      'diagnosis': diagnosis,
      'recommendations': recommendations,
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'screeningResultId': screeningResultId,
      'rescheduleReason': rescheduleReason,
      'rescheduledAt': rescheduledAt != null ? Timestamp.fromDate(rescheduledAt!) : null,
    };
  }

  factory DoctorAppointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return DoctorAppointment(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Unknown Patient',
      patientAge: data['patientAge'] ?? 0,
      patientGender: data['patientGender'] ?? 'Unknown',
      patientImageUrl: data['patientImageUrl'],
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      scheduledAt: parseTimestamp(data['scheduledAt']),
      requestedAt: parseTimestamp(data['requestedAt']),
      consultationType: ConsultationType.fromString(data['consultationType']),
      status: AppointmentStatus.fromString(data['status']),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      notes: data['notes'],
      diagnosis: data['diagnosis'],
      recommendations: data['recommendations'],
      followUpDate: data['followUpDate'] != null
          ? parseTimestamp(data['followUpDate'])
          : null,
      screeningResultId: data['screeningResultId'],
      rescheduleReason: data['rescheduleReason'],
      rescheduledAt: data['rescheduledAt'] != null
          ? parseTimestamp(data['rescheduledAt'])
          : null,
    );
  }

  DoctorAppointment copyWith({
    AppointmentStatus? status,
    String? notes,
    String? diagnosis,
    String? recommendations,
    DateTime? followUpDate,
    DateTime? scheduledAt,
    String? rescheduleReason,
    DateTime? rescheduledAt,
  }) {
    return DoctorAppointment(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientAge: patientAge,
      patientGender: patientGender,
      patientImageUrl: patientImageUrl,
      doctorId: doctorId,
      doctorName: doctorName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      requestedAt: requestedAt,
      consultationType: consultationType,
      status: status ?? this.status,
      symptoms: symptoms,
      notes: notes ?? this.notes,
      diagnosis: diagnosis ?? this.diagnosis,
      recommendations: recommendations ?? this.recommendations,
      followUpDate: followUpDate ?? this.followUpDate,
      screeningResultId: screeningResultId,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
    );
  }
}
