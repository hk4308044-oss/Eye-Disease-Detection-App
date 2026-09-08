import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an administrative audit log entry stored in Firestore `audit_logs/{id}`
class AuditLog {
  final String id;
  final String adminUid;
  final String adminName;
  final String action; // e.g., 'User Created', 'Doctor Approved', 'Doctor Suspended', 'Appointment Rescheduled'
  final String targetType; // 'User', 'Doctor', 'Appointment', 'Screening', 'Content', 'Notification'
  final String targetId;
  final String details;
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.adminUid,
    required this.adminName,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'adminUid': adminUid,
      'adminName': adminName,
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory AuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return AuditLog(
      id: doc.id,
      adminUid: data['adminUid'] ?? '',
      adminName: data['adminName'] ?? 'Admin',
      action: data['action'] ?? 'Unknown Action',
      targetType: data['targetType'] ?? 'System',
      targetId: data['targetId'] ?? '',
      details: data['details'] ?? '',
      timestamp: parseTimestamp(data['timestamp']),
    );
  }
}
