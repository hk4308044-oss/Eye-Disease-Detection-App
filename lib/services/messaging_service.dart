import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';

/// Firestore-backed real-time messaging service.
/// Collection structure:
///   conversations/{conversationId}
///   conversations/{conversationId}/messages/{messageId}
class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;
  String get currentName =>
      _auth.currentUser?.displayName ??
      _auth.currentUser?.email?.split('@').first ??
      'User';

  // ──────────────────────────────────
  // CONVERSATIONS
  // ──────────────────────────────────

  /// Find an existing conversation between patient and doctor, or create one.
  Future<ChatConversation> getOrCreateConversation({
    required String doctorId,
    required String doctorName,
    String? doctorSpecialty,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Not authenticated');

    try {
      // Check if a conversation already exists between these two users
      final existing = await _db
          .collection('conversations')
          .where('patientId', isEqualTo: uid)
          .where('doctorId', isEqualTo: doctorId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return ChatConversation.fromMap(
          existing.docs.first.data(),
          existing.docs.first.id,
        );
      }

      // Create a new conversation
      final convo = ChatConversation(
        id: '', // will be set by Firestore
        patientId: uid,
        patientName: currentName,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
      );

      final ref = await _db.collection('conversations').add(convo.toMap());
      return ChatConversation(
        id: ref.id,
        patientId: uid,
        patientName: currentName,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
      );
    } catch (e) {
      debugPrint('MessagingService.getOrCreateConversation error: $e');
      rethrow;
    }
  }

  /// Stream all conversations for the current user (patient or doctor).
  Stream<List<ChatConversation>> streamConversations() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatConversation.fromMap(d.data(), d.id))
            .toList());
  }

  // ──────────────────────────────────
  // MESSAGES
  // ──────────────────────────────────

  /// Send a text message in a conversation.
  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    required String text,
  }) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Not authenticated');
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final message = ChatMessage(
      id: '',
      senderId: uid,
      senderName: currentName,
      receiverId: receiverId,
      text: text.trim(),
      timestamp: now,
    );

    try {
      // Add message to subcollection
      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());

      // Determine which unread counter to bump
      final convoDoc =
          await _db.collection('conversations').doc(conversationId).get();
      final convoData = convoDoc.data() ?? {};
      final patientId = convoData['patientId'] ?? '';

      final isPatientSender = uid == patientId;

      // Update conversation metadata
      await _db.collection('conversations').doc(conversationId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': Timestamp.fromDate(now),
        'lastSenderId': uid,
        if (isPatientSender)
          'unreadCountDoctor': FieldValue.increment(1)
        else
          'unreadCountPatient': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('MessagingService.sendMessage error: $e');
      rethrow;
    }
  }

  /// Stream messages in a conversation, ordered by time ascending.
  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage.fromMap(d.data(), d.id))
            .toList());
  }

  /// Mark all messages in a conversation as read for the current user.
  Future<void> markAsRead(String conversationId) async {
    final uid = currentUid;
    if (uid == null) return;

    try {
      final convoDoc =
          await _db.collection('conversations').doc(conversationId).get();
      final convoData = convoDoc.data() ?? {};
      final patientId = convoData['patientId'] ?? '';

      final isPatient = uid == patientId;

      // Reset the unread counter for the current user
      await _db.collection('conversations').doc(conversationId).update({
        if (isPatient) 'unreadCountPatient': 0 else 'unreadCountDoctor': 0,
      });

      // Mark individual messages as read
      final unread = await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();

      if (unread.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in unread.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('MessagingService.markAsRead error: $e');
    }
  }

  /// Get total unread message count across all conversations for the current user.
  Stream<int> streamTotalUnreadCount() {
    final uid = currentUid;
    if (uid == null) return Stream.value(0);

    return _db
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      int total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final patientId = data['patientId'] ?? '';
        if (uid == patientId) {
          total += (data['unreadCountPatient'] as int? ?? 0);
        } else {
          total += (data['unreadCountDoctor'] as int? ?? 0);
        }
      }
      return total;
    });
  }
}
