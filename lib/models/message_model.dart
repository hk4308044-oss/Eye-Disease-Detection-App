import 'package:cloud_firestore/cloud_firestore.dart';

/// A single chat message between two users.
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

/// A conversation between a patient and a doctor.
class ChatConversation {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialty;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastSenderId;
  final int unreadCountPatient;
  final int unreadCountDoctor;

  ChatConversation({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialty,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSenderId,
    this.unreadCountPatient = 0,
    this.unreadCountDoctor = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : FieldValue.serverTimestamp(),
      'lastSenderId': lastSenderId,
      'unreadCountPatient': unreadCountPatient,
      'unreadCountDoctor': unreadCountDoctor,
      'participants': [patientId, doctorId],
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map, String docId) {
    return ChatConversation(
      id: docId,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'],
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] is Timestamp
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastSenderId: map['lastSenderId'],
      unreadCountPatient: map['unreadCountPatient'] ?? 0,
      unreadCountDoctor: map['unreadCountDoctor'] ?? 0,
    );
  }
}
