import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/doctor_profile.dart';
import '../models/doctor_appointment.dart';
import '../models/patient_record.dart';
import '../models/eye_screening_result.dart';

/// All Firestore operations for the Doctor Portal.
/// Doctors can only access data they are authorized to access.
class DoctorService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  String? get currentUid => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────
  // DOCTOR PROFILE
  // ─────────────────────────────────────────────

  /// Fetch the doctor's own profile from `doctors/{uid}`
  /// If missing, falls back to initializing from `users/{uid}` / Auth.
  Future<DoctorProfile?> getDoctorProfile() async {
    final uid = currentUid;
    if (uid == null) return null;
    try {
      final doc = await _db.collection('doctors').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return DoctorProfile.fromMap(doc.data()!, uid);
      }

      // Fallback: If doctors/{uid} doesn't exist yet, check users/{uid}
      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final authUser = _auth.currentUser;

      final defaultProfile = DoctorProfile(
        uid: uid,
        name: userData['name'] ?? authUser?.displayName ?? 'Doctor',
        email: userData['email'] ?? authUser?.email ?? '',
        specialization: userData['specialization'] ?? 'Ophthalmology Specialist',
        qualification: userData['qualification'] ?? 'MBBS, FCPS (Ophthalmology)',
        licenseNumber: userData['licenseNumber'] ?? 'PMC-${uid.substring(0, 5).toUpperCase()}',
        clinicName: userData['clinicName'] ?? 'VisionAI Eye Care Clinic',
        clinicLocation: userData['clinicLocation'] ?? 'Main Clinical Center',
        consultationFee: (userData['consultationFee'] as num?)?.toDouble() ?? 2000.0,
        profileImageUrl: userData['profileImageUrl'] ?? authUser?.photoURL,
        bio: userData['bio'] ?? 'Specialist in comprehensive eye health screening, retina care, and AI diagnostic validation.',
        experienceYears: userData['experienceYears'] ?? 6,
        role: 'doctor',
      );

      // Auto-save so future reads find it immediately
      await _db.collection('doctors').doc(uid).set(defaultProfile.toMap(), SetOptions(merge: true));
      return defaultProfile;
    } catch (e) {
      debugPrint('DoctorService.getDoctorProfile error: $e');
      return null;
    }
  }

  /// Upload doctor profile photo to Firebase Storage and update profile
  Future<String?> uploadProfileImage(File imageFile) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Not authenticated');
    try {
      final ref = _storage.ref().child('doctors/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _db.collection('doctors').doc(uid).set({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _db.collection('users').doc(uid).set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      return downloadUrl;
    } catch (e) {
      debugPrint('DoctorService.uploadProfileImage error: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Stream the doctor's own profile for real-time updates
  Stream<DoctorProfile?> streamDoctorProfile() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db.collection('doctors').doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return DoctorProfile.fromMap(snap.data()!, snap.id);
    });
  }

  /// Save or update the doctor's profile
  Future<void> saveDoctorProfile(DoctorProfile profile) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Not authenticated');
    try {
      await _db.collection('doctors').doc(uid).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
      // Also update name in the users collection
      await _db.collection('users').doc(uid).set(
        {'name': profile.name, 'role': 'doctor'},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('DoctorService.saveDoctorProfile error: $e');
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Toggle availability status
  Future<void> setAvailability(bool isAvailable) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('doctors').doc(uid).update({'isAvailable': isAvailable});
  }

  // ─────────────────────────────────────────────
  // APPOINTMENTS
  // ─────────────────────────────────────────────

  /// Stream all appointments for this doctor (real-time)
  Stream<List<DoctorAppointment>> streamAllAppointments() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList());
  }

  /// Stream appointments by status
  Stream<List<DoctorAppointment>> streamAppointmentsByStatus(
      AppointmentStatus status) {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('status', isEqualTo: status.name)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList());
  }

  /// Stream pending appointment requests
  Stream<List<DoctorAppointment>> streamPendingRequests() =>
      streamAppointmentsByStatus(AppointmentStatus.pending);

  /// Stream upcoming (confirmed) appointments
  Stream<List<DoctorAppointment>> streamUpcomingAppointments() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    final now = Timestamp.fromDate(DateTime.now());
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('status', whereIn: [
          AppointmentStatus.confirmed.name,
          AppointmentStatus.rescheduled.name
        ])
        .where('scheduledAt', isGreaterThanOrEqualTo: now)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList());
  }

  /// Stream today's appointments
  Stream<List<DoctorAppointment>> streamTodayAppointments() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .where('scheduledAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList());
  }

  /// Accept an appointment (pending → confirmed)
  Future<void> acceptAppointment(String appointmentId) async {
    await _updateAppointmentStatus(appointmentId, AppointmentStatus.confirmed);
    await _createNotification(
      appointmentId: appointmentId,
      type: 'appointment_confirmed',
      title: 'Appointment Confirmed',
      body: 'Your appointment has been confirmed by the doctor.',
    );
  }

  /// Reject an appointment
  Future<void> rejectAppointment(String appointmentId, {String? reason}) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.rejected.name,
      'rescheduleReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _createNotification(
      appointmentId: appointmentId,
      type: 'appointment_rejected',
      title: 'Appointment Update',
      body: reason != null
          ? 'Your appointment request was not accepted: $reason'
          : 'Your appointment request was not accepted.',
    );
  }

  /// Reschedule an appointment
  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime, {
    String? reason,
  }) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.rescheduled.name,
      'scheduledAt': Timestamp.fromDate(newDateTime),
      'rescheduledAt': FieldValue.serverTimestamp(),
      'rescheduleReason': reason ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _createNotification(
      appointmentId: appointmentId,
      type: 'appointment_rescheduled',
      title: 'Appointment Rescheduled',
      body: 'Your appointment has been rescheduled.',
    );
  }

  /// Mark appointment as completed and add clinical notes
  Future<void> completeAppointment(
    String appointmentId, {
    required String notes,
    required String diagnosis,
    required String recommendations,
    DateTime? followUpDate,
  }) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.completed.name,
      'notes': notes,
      'diagnosis': diagnosis,
      'recommendations': recommendations,
      'followUpDate': followUpDate != null
          ? Timestamp.fromDate(followUpDate)
          : null,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    await _updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
  }

  /// Add/update doctor notes on an appointment without completing it
  Future<void> updateAppointmentNotes(String appointmentId, String notes) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────
  // PATIENTS
  // ─────────────────────────────────────────────

  /// Get all unique patient IDs for this doctor (from their appointments)
  Future<List<String>> getMyPatientIds() async {
    final uid = currentUid;
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('appointments')
          .where('doctorId', isEqualTo: uid)
          .where('status', whereIn: [
            AppointmentStatus.confirmed.name,
            AppointmentStatus.completed.name,
            AppointmentStatus.rescheduled.name,
          ])
          .get();
      final ids = snap.docs
          .map((d) => d.data()['patientId'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      return ids;
    } catch (e) {
      debugPrint('DoctorService.getMyPatientIds error: $e');
      return [];
    }
  }

  /// Fetch a patient's basic profile (doctors can read user profiles of their patients)
  Future<PatientRecord?> getPatientRecord(String patientId) async {
    try {
      final userDoc = await _db.collection('users').doc(patientId).get();
      if (!userDoc.exists) return null;
      final data = userDoc.data()!;

      // Fetch their screenings
      final screenings = await getPatientScreenings(patientId);

      return PatientRecord.fromMap(data, patientId, screenings: screenings);
    } catch (e) {
      debugPrint('DoctorService.getPatientRecord error: $e');
      return null;
    }
  }

  /// Fetch all of this doctor's patients with their records
  Future<List<PatientRecord>> getMyPatients() async {
    final patientIds = await getMyPatientIds();
    final records = <PatientRecord>[];
    for (final id in patientIds) {
      final record = await getPatientRecord(id);
      if (record != null) records.add(record);
    }
    return records;
  }

  /// Stream of doctor's patients
  Stream<List<PatientRecord>> streamPatients() async* {
    final patients = await getMyPatients();
    yield patients;
  }

  // ─────────────────────────────────────────────
  // AI SCREENING RESULTS (read-only for doctor)
  // ─────────────────────────────────────────────

  /// Fetch a patient's AI screening results
  Future<List<EyeScreeningResult>> getPatientScreenings(String patientId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(patientId)
          .collection('screenings')
          .orderBy('date', descending: true)
          .get();
      return snap.docs
          .map((d) => EyeScreeningResult.fromFirestore(d.data(), d.id))
          .toList();
    } catch (e) {
      debugPrint('DoctorService.getPatientScreenings error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // DASHBOARD STATS
  // ─────────────────────────────────────────────

  /// Get dashboard summary stats for the doctor
  Future<Map<String, int>> getDashboardStats() async {
    final uid = currentUid;
    if (uid == null) return {};
    try {
      final snap =
          await _db.collection('appointments').where('doctorId', isEqualTo: uid).get();
      final all = snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayAppts = all
          .where((a) =>
              a.scheduledAt.isAfter(startOfDay) &&
              a.scheduledAt.isBefore(endOfDay))
          .length;

      final pending = all
          .where((a) => a.status == AppointmentStatus.pending)
          .length;

      final upcoming = all
          .where((a) =>
              (a.status == AppointmentStatus.confirmed ||
                  a.status == AppointmentStatus.rescheduled) &&
              a.scheduledAt.isAfter(now))
          .length;

      final completed = all
          .where((a) => a.status == AppointmentStatus.completed)
          .length;

      final onlineConsultations = all
          .where((a) =>
              a.consultationType == ConsultationType.online &&
              a.status == AppointmentStatus.completed)
          .length;

      final patientIds = all
          .map((a) => a.patientId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .length;

      return {
        'today': todayAppts,
        'pending': pending,
        'upcoming': upcoming,
        'totalPatients': patientIds,
        'completed': completed,
        'online': onlineConsultations,
      };
    } catch (e) {
      debugPrint('DoctorService.getDashboardStats error: $e');
      return {
        'today': 0,
        'pending': 0,
        'upcoming': 0,
        'totalPatients': 0,
        'completed': 0,
        'online': 0,
      };
    }
  }

  // ─────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────

  /// Stream in-app notifications for the current doctor
  Stream<List<Map<String, dynamic>>> streamNotifications() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  /// Mark a notification as read
  Future<void> markNotificationRead(String notifId) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .doc(notifId)
        .update({'read': true});
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    final uid = currentUid;
    if (uid == null) return;
    final snap = await _db
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .where('read', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  /// Internal helper — create notification for a patient
  Future<void> _createNotification({
    required String appointmentId,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      // Read patient ID from appointment to notify them
      final apptDoc =
          await _db.collection('appointments').doc(appointmentId).get();
      if (!apptDoc.exists) return;
      final patientId = apptDoc.data()?['patientId'] as String?;
      if (patientId == null || patientId.isEmpty) return;

      await _db
          .collection('notifications')
          .doc(patientId)
          .collection('items')
          .add({
        'type': type,
        'title': title,
        'body': body,
        'appointmentId': appointmentId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // FCM_INTEGRATION_POINT: Send push notification via Firebase Cloud Messaging
      // When FCM is configured, call your cloud function or FCM REST API here
      // to deliver a push notification to the patient's device token.
    } catch (e) {
      debugPrint('DoctorService._createNotification error: $e');
    }
  }

  /// Create a notification for the current doctor (e.g., new patient request)
  Future<void> createDoctorNotification({
    required String title,
    required String body,
    required String type,
    String? appointmentId,
  }) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _db
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .add({
        'type': type,
        'title': title,
        'body': body,
        'appointmentId': appointmentId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('DoctorService.createDoctorNotification error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // APPOINTMENTS — Patient side (book with doctor)
  // ─────────────────────────────────────────────

  /// Patient creates an appointment request
  /// This is also used by patients, exposed here for completeness
  Future<String> createAppointmentRequest(DoctorAppointment appointment) async {
    try {
      final ref = await _db.collection('appointments').add(appointment.toMap()
        ..addAll({'createdAt': FieldValue.serverTimestamp()}));
      // Notify doctor of new request
      await _db
          .collection('notifications')
          .doc(appointment.doctorId)
          .collection('items')
          .add({
        'type': 'new_appointment_request',
        'title': 'New Appointment Request',
        'body': '${appointment.patientName} has requested an appointment.',
        'appointmentId': ref.id,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  /// Get appointments for the patient-doctor appointment history
  Future<List<DoctorAppointment>> getPatientAppointmentsWithDoctor(
      String patientId) async {
    final uid = currentUid;
    if (uid == null) return [];
    try {
      final snap = await _db
          .collection('appointments')
          .where('doctorId', isEqualTo: uid)
          .where('patientId', isEqualTo: patientId)
          .orderBy('scheduledAt', descending: true)
          .get();
      return snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('DoctorService.getPatientAppointmentsWithDoctor error: $e');
      return [];
    }
  }
}
