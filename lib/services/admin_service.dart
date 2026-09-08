import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/doctor_profile.dart';
import '../models/doctor_appointment.dart';
import '../models/eye_screening_result.dart';
import '../models/audit_log.dart';
import '../models/content_item.dart';

/// Centralized Service for Admin Portal operations.
/// All administrative actions require role == 'admin' authorization.
class AdminService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get currentAdminUid => _auth.currentUser?.uid;
  String get currentAdminName => _auth.currentUser?.displayName ?? 'Admin';

  // ─────────────────────────────────────────────
  // AUDIT LOGGING
  // ─────────────────────────────────────────────

  /// Record an administrative action into `audit_logs`
  Future<void> logAction({
    required String action,
    required String targetType,
    required String targetId,
    required String details,
  }) async {
    try {
      final uid = currentAdminUid ?? 'system';
      await _db.collection('audit_logs').add({
        'adminUid': uid,
        'adminName': currentAdminName,
        'action': action,
        'targetType': targetType,
        'targetId': targetId,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('AdminService.logAction error: $e');
    }
  }

  /// Stream real-time system audit logs
  Stream<List<AuditLog>> streamAuditLogs({int limit = 50}) {
    return _db
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AuditLog.fromFirestore(d)).toList());
  }

  // ─────────────────────────────────────────────
  // DASHBOARD OVERVIEW & ANALYTICS
  // ─────────────────────────────────────────────

  /// Fetch aggregated platform overview statistics
  Future<Map<String, int>> getPlatformStats() async {
    try {
      final usersSnap = await _db.collection('users').get();
      final doctorsSnap = await _db.collection('doctors').get();
      final apptsSnap = await _db.collection('appointments').get();

      int totalPatients = 0;
      int activeUsers = 0;
      for (var doc in usersSnap.docs) {
        final data = doc.data();
        final role = data['role'] ?? 'user';
        if (role == 'user' || role == 'patient') {
          totalPatients++;
        }
        if (data['isActive'] != false) {
          activeUsers++;
        }
      }

      int totalDoctors = doctorsSnap.docs.length;
      int activeDoctors = 0;
      int pendingDoctorApprovals = 0;

      for (var doc in doctorsSnap.docs) {
        final data = doc.data();
        final isAvail = data['isAvailable'] ?? true;
        final status = data['status'] ?? (data['isAvailable'] == true ? 'approved' : 'pending');
        if (status == 'pending') {
          pendingDoctorApprovals++;
        } else if (isAvail) {
          activeDoctors++;
        }
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      int todaysAppts = 0;
      int upcomingAppts = 0;
      int completedConsultations = 0;
      int onlineConsultations = 0;

      for (var doc in apptsSnap.docs) {
        final appt = DoctorAppointment.fromFirestore(doc);
        if (appt.scheduledAt.isAfter(startOfDay) && appt.scheduledAt.isBefore(endOfDay)) {
          todaysAppts++;
        }
        if (appt.scheduledAt.isAfter(now) &&
            (appt.status == AppointmentStatus.confirmed || appt.status == AppointmentStatus.rescheduled)) {
          upcomingAppts++;
        }
        if (appt.status == AppointmentStatus.completed) {
          completedConsultations++;
          if (appt.consultationType == ConsultationType.online) {
            onlineConsultations++;
          }
        }
      }

      // Count screenings across users using single collectionGroup query
      int totalScreenings = 0;
      int flaggedScreenings = 0;

      try {
        final screeningsSnap = await _db.collectionGroup('screenings').get();
        totalScreenings = screeningsSnap.docs.length;
        for (var sDoc in screeningsSnap.docs) {
          final sData = sDoc.data();
          final risk = (sData['riskLevel'] ?? '').toString().toLowerCase();
          if (risk == 'high' || risk == 'attention' || risk == 'severe' || risk == 'moderate') {
            flaggedScreenings++;
          }
        }
      } catch (e) {
        debugPrint('collectionGroup screenings query fallback: $e');
      }

      return {
        'totalPatients': totalPatients,
        'totalDoctors': totalDoctors,
        'activeDoctors': activeDoctors,
        'pendingApprovals': pendingDoctorApprovals,
        'todaysAppointments': todaysAppts,
        'upcomingAppointments': upcomingAppts,
        'completedConsultations': completedConsultations,
        'onlineConsultations': onlineConsultations,
        'totalScreenings': totalScreenings,
        'flaggedScreenings': flaggedScreenings,
        'activeUsers': activeUsers,
      };
    } catch (e) {
      debugPrint('AdminService.getPlatformStats error: $e');
      return {
        'totalPatients': 0,
        'totalDoctors': 0,
        'activeDoctors': 0,
        'pendingApprovals': 0,
        'todaysAppointments': 0,
        'upcomingAppointments': 0,
        'completedConsultations': 0,
        'onlineConsultations': 0,
        'totalScreenings': 0,
        'flaggedScreenings': 0,
        'activeUsers': 0,
      };
    }
  }

  // ─────────────────────────────────────────────
  // USER (PATIENT) MANAGEMENT
  // ─────────────────────────────────────────────

  /// Stream or fetch all patient profiles
  Stream<List<UserProfile>> streamAllPatients() {
    return _db.collection('users').snapshots().map((snap) {
      return snap.docs
          .map((d) => UserProfile.fromMap(d.data(), d.id))
          .where((p) => p.role == 'user' || p.role == 'patient')
          .toList();
    });
  }

  /// Toggle user account active / suspended status
  Future<void> setUserAccountStatus(String uid, bool isActive, {String? name}) async {
    await _db.collection('users').doc(uid).set(
      {'isActive': isActive, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );

    await logAction(
      action: isActive ? 'Account Activated' : 'Account Suspended',
      targetType: 'User',
      targetId: uid,
      details: 'Patient ${name ?? uid} account ${isActive ? 'activated' : 'suspended'}.',
    );
  }

  /// Update user profile details from admin console
  Future<void> updatePatientProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.id).set(
      profile.toMap()..addAll({'updatedAt': FieldValue.serverTimestamp()}),
      SetOptions(merge: true),
    );

    await logAction(
      action: 'User Profile Updated',
      targetType: 'User',
      targetId: profile.id,
      details: 'Updated details for patient ${profile.name}.',
    );
  }

  // ─────────────────────────────────────────────
  // DOCTOR MANAGEMENT & WORKFLOW
  // ─────────────────────────────────────────────

  /// Stream all doctors with optional filter
  Stream<List<DoctorProfile>> streamAllDoctors() {
    return _db.collection('doctors').snapshots().map((snap) {
      return snap.docs.map((d) => DoctorProfile.fromMap(d.data(), d.id)).toList();
    });
  }

  /// Doctor approval state machine: Pending -> Approved
  Future<void> approveDoctor(String doctorUid, String doctorName) async {
    await _db.collection('doctors').doc(doctorUid).set({
      'isAvailable': true,
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('users').doc(doctorUid).set({
      'role': 'doctor',
      'status': 'approved',
    }, SetOptions(merge: true));

    // Send notification to doctor
    await sendNotification(
      targetUid: doctorUid,
      title: 'Doctor Account Approved',
      body: 'Congratulations Dr. $doctorName! Your doctor credentials have been verified and approved.',
      type: 'approval',
    );

    await logAction(
      action: 'Doctor Approved',
      targetType: 'Doctor',
      targetId: doctorUid,
      details: 'Approved doctor account for Dr. $doctorName.',
    );
  }

  /// Reject pending doctor request
  Future<void> rejectDoctor(String doctorUid, String doctorName, {String? reason}) async {
    await _db.collection('doctors').doc(doctorUid).set({
      'isAvailable': false,
      'status': 'rejected',
      'rejectionReason': reason ?? '',
    }, SetOptions(merge: true));

    await sendNotification(
      targetUid: doctorUid,
      title: 'Doctor Application Status',
      body: 'Your doctor application was not approved. ${reason ?? ''}',
      type: 'rejection',
    );

    await logAction(
      action: 'Doctor Rejected',
      targetType: 'Doctor',
      targetId: doctorUid,
      details: 'Rejected doctor application for Dr. $doctorName. Reason: ${reason ?? 'N/A'}',
    );
  }

  /// Suspend or Deactivate a doctor
  Future<void> setDoctorStatus(String doctorUid, String doctorName, bool isAvailable) async {
    await _db.collection('doctors').doc(doctorUid).update({
      'isAvailable': isAvailable,
      'status': isAvailable ? 'approved' : 'suspended',
    });

    await logAction(
      action: isAvailable ? 'Doctor Activated' : 'Doctor Suspended',
      targetType: 'Doctor',
      targetId: doctorUid,
      details: '${isAvailable ? 'Activated' : 'Suspended'} doctor account for Dr. $doctorName.',
    );
  }

  /// Add a new doctor manually by Admin
  Future<void> addDoctor(DoctorProfile doctor) async {
    await _db.collection('doctors').doc(doctor.uid).set(
          doctor.toMap()..addAll({'status': 'approved', 'isAvailable': true}),
        );

    // Also update role in users collection
    await _db.collection('users').doc(doctor.uid).set({
      'name': doctor.name,
      'email': doctor.email,
      'role': 'doctor',
      'status': 'approved',
    }, SetOptions(merge: true));

    await logAction(
      action: 'Doctor Created',
      targetType: 'Doctor',
      targetId: doctor.uid,
      details: 'Admin created doctor account for Dr. ${doctor.name}.',
    );
  }

  /// Update doctor profile from Admin Portal
  Future<void> updateDoctorProfile(DoctorProfile doctor) async {
    await _db.collection('doctors').doc(doctor.uid).set(
          doctor.toMap(),
          SetOptions(merge: true),
        );

    await logAction(
      action: 'Doctor Profile Updated',
      targetType: 'Doctor',
      targetId: doctor.uid,
      details: 'Updated profile for Dr. ${doctor.name}.',
    );
  }

  // ─────────────────────────────────────────────
  // APPOINTMENT MANAGEMENT
  // ─────────────────────────────────────────────

  /// Stream all system appointments
  Stream<List<DoctorAppointment>> streamAllAppointments() {
    return _db
        .collection('appointments')
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => DoctorAppointment.fromFirestore(d)).toList());
  }

  /// Administrative appointment creation
  Future<void> createAppointment(DoctorAppointment appt) async {
    final ref = await _db.collection('appointments').add(
          appt.toMap()..addAll({'createdAt': FieldValue.serverTimestamp()}),
        );

    await logAction(
      action: 'Appointment Created',
      targetType: 'Appointment',
      targetId: ref.id,
      details: 'Admin scheduled appointment for ${appt.patientName} with Dr. ${appt.doctorName}.',
    );
  }

  /// Reschedule an appointment as Admin
  Future<void> rescheduleAppointment(String apptId, DateTime newDateTime, {String? reason}) async {
    await _db.collection('appointments').doc(apptId).update({
      'scheduledAt': Timestamp.fromDate(newDateTime),
      'status': AppointmentStatus.rescheduled.name,
      'rescheduleReason': reason ?? 'Rescheduled by Admin',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logAction(
      action: 'Appointment Rescheduled',
      targetType: 'Appointment',
      targetId: apptId,
      details: 'Rescheduled appointment to ${newDateTime.toString()}.',
    );
  }

  /// Reassign appointment to a different doctor
  Future<void> reassignAppointmentDoctor(
    String apptId,
    String newDoctorId,
    String newDoctorName,
  ) async {
    await _db.collection('appointments').doc(apptId).update({
      'doctorId': newDoctorId,
      'doctorName': newDoctorName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logAction(
      action: 'Doctor Reassigned',
      targetType: 'Appointment',
      targetId: apptId,
      details: 'Reassigned appointment to Dr. $newDoctorName.',
    );
  }

  /// Update appointment status
  Future<void> setAppointmentStatus(String apptId, AppointmentStatus status) async {
    await _db.collection('appointments').doc(apptId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await logAction(
      action: 'Appointment Status Updated',
      targetType: 'Appointment',
      targetId: apptId,
      details: 'Status changed to ${status.label}.',
    );
  }

  // ─────────────────────────────────────────────
  // AI SCREENINGS MANAGEMENT
  // ─────────────────────────────────────────────

  /// Fetch system-wide AI screening reports
  Future<List<Map<String, dynamic>>> getSystemWideScreenings() async {
    try {
      final usersSnap = await _db.collection('users').get();
      final all = <Map<String, dynamic>>[];

      for (var userDoc in usersSnap.docs) {
        final userData = userDoc.data();
        final screeningsSnap = await userDoc.reference.collection('screenings').orderBy('date', descending: true).get();

        for (var sDoc in screeningsSnap.docs) {
          final result = EyeScreeningResult.fromFirestore(sDoc.data(), sDoc.id);
          all.add({
            'patientId': userDoc.id,
            'patientName': userData['name'] ?? 'Patient',
            'patientAge': userData['age'] ?? 0,
            'patientGender': userData['gender'] ?? 'Unknown',
            'screening': result,
          });
        }
      }
      return all;
    } catch (e) {
      debugPrint('AdminService.getSystemWideScreenings error: $e');
      return [];
    }
  }

  /// Purge old screening records per data retention policy
  Future<int> purgeScreeningsOlderThan(int daysOld) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    int count = 0;
    try {
      final usersSnap = await _db.collection('users').get();
      final batch = _db.batch();

      for (var userDoc in usersSnap.docs) {
        final sSnap = await userDoc.reference
            .collection('screenings')
            .where('date', isLessThan: Timestamp.fromDate(cutoff))
            .get();

        for (var doc in sSnap.docs) {
          batch.delete(doc.reference);
          count++;
        }
      }
      await batch.commit();

      await logAction(
        action: 'Data Retention Policy Purge',
        targetType: 'Screening',
        targetId: 'batch',
        details: 'Purged $count screening records older than $daysOld days.',
      );
    } catch (e) {
      debugPrint('AdminService.purgeScreeningsOlderThan error: $e');
    }
    return count;
  }

  // ─────────────────────────────────────────────
  // CONTENT MANAGEMENT
  // ─────────────────────────────────────────────

  /// Stream content items by category or all
  Stream<List<ContentItem>> streamContentItems({ContentCategory? category}) {
    Query query = _db.collection('content_items');
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => ContentItem.fromFirestore(d)).toList(),
        );
  }

  /// Save or update content item
  Future<void> saveContentItem(ContentItem item) async {
    final ref = item.id.isNotEmpty
        ? _db.collection('content_items').doc(item.id)
        : _db.collection('content_items').doc();

    await ref.set(item.toMap(), SetOptions(merge: true));

    await logAction(
      action: item.id.isNotEmpty ? 'Content Updated' : 'Content Created',
      targetType: 'Content',
      targetId: ref.id,
      details: '${item.category.label}: "${item.title}"',
    );
  }

  /// Delete content item
  Future<void> deleteContentItem(String id, String title) async {
    await _db.collection('content_items').doc(id).delete();
    await logAction(
      action: 'Content Deleted',
      targetType: 'Content',
      targetId: id,
      details: 'Deleted content item: "$title"',
    );
  }

  // ─────────────────────────────────────────────
  // NOTIFICATION MANAGEMENT
  // ─────────────────────────────────────────────

  /// Broadcast or target a notification
  Future<void> sendNotification({
    String? targetUid,
    String? targetRole, // 'all', 'patient', 'doctor'
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      if (targetUid != null && targetUid.isNotEmpty) {
        // Target single user
        await _db.collection('notifications').doc(targetUid).collection('items').add({
          'type': type,
          'title': title,
          'body': body,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'sender': 'Admin',
        });
      } else {
        // Broadcast to matching users
        final usersSnap = await _db.collection('users').get();
        final batch = _db.batch();

        for (var doc in usersSnap.docs) {
          final role = doc.data()['role'] ?? 'user';
          bool matches = targetRole == 'all' ||
              (targetRole == 'patient' && (role == 'user' || role == 'patient')) ||
              (targetRole == 'doctor' && role == 'doctor');

          if (matches) {
            final notifRef = _db.collection('notifications').doc(doc.id).collection('items').doc();
            batch.set(notifRef, {
              'type': type,
              'title': title,
              'body': body,
              'read': false,
              'createdAt': FieldValue.serverTimestamp(),
              'sender': 'Admin Broadcast',
            });
          }
        }
        await batch.commit();
      }

      await logAction(
        action: 'Notification Dispatched',
        targetType: 'Notification',
        targetId: targetUid ?? targetRole ?? 'broadcast',
        details: 'Sent "$title" to ${targetUid ?? targetRole}.',
      );
    } catch (e) {
      debugPrint('AdminService.sendNotification error: $e');
    }
  }
}
