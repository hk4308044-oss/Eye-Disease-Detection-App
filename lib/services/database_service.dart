import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/screening_record.dart';
import '../models/user_profile.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> saveScreening(ScreeningRecord record) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception("User is not logged in. Cannot save screening.");
    }
    
    // Save under users/{uid}/screenings/{screeningId}
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .doc(record.id)
        .set(record.toMap());
  }

  Future<List<ScreeningRecord>> getUserScreenings() async {
    final uid = currentUserId;
    if (uid == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return ScreeningRecord.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception("User is not logged in. Cannot save profile.");
    }
    
    await _firestore
        .collection('users')
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile() async {
    final uid = currentUserId;
    if (uid == null) {
      return null;
    }

    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return UserProfile.fromMap(docSnapshot.data()!, docSnapshot.id);
    }
    
    return null;
  }
}
