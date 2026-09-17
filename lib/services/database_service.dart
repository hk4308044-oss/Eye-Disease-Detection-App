import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/screening_record.dart';
import '../models/user_profile.dart';
import 'database_helper.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if SQLite is available (not on web)
  bool get _canUseSQLite => !kIsWeb;

  /// 1. Save screening record: ALWAYS save to SQLite first!
  Future<void> saveScreening(ScreeningRecord record) async {
    if (_canUseSQLite) {
      // Save to local SQLite database first (Offline-First)
      await DatabaseHelper.instance.insertScreeningRecord(record);
      debugPrint("✅ Saved screening record to local SQLite DB: ${record.id}");
    }

    // Sync to Firebase
    await _trySyncScreeningToFirebase(record);
  }

  Future<void> _trySyncScreeningToFirebase(ScreeningRecord record) async {
    try {
      final uid = currentUserId;
      if (uid != null) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('screenings')
            .doc(record.id)
            .set(record.toMap())
            .timeout(const Duration(seconds: 4));
        debugPrint("☁️ Synced screening record to Firebase Cloud");
      }
    } catch (e) {
      debugPrint("ℹ️ Firebase sync skipped/failed (Offline mode active): $e");
    }
  }

  /// 2. Get user screening records: Read from SQLite first
  Future<List<ScreeningRecord>> getUserScreenings() async {
    // On web, skip SQLite entirely and go straight to Firebase
    if (_canUseSQLite) {
      // Try fetching from local SQLite first
      final localRecords = await DatabaseHelper.instance.getAllScreeningRecords();
      if (localRecords.isNotEmpty) {
        debugPrint("📱 Loaded ${localRecords.length} records from local SQLite");
        return localRecords;
      }
    }

    // Fallback: If local SQLite is empty or on web, try loading from Firebase
    try {
      final uid = currentUserId;
      if (uid != null) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('screenings')
            .orderBy('date', descending: true)
            .get()
            .timeout(const Duration(seconds: 4));

        final remoteRecords = querySnapshot.docs.map((doc) {
          return ScreeningRecord.fromMap(doc.data(), doc.id);
        }).toList();

        // Cache into local SQLite for offline access next time (not on web)
        if (_canUseSQLite) {
          for (var record in remoteRecords) {
            await DatabaseHelper.instance.insertScreeningRecord(record);
          }
        }

        return remoteRecords;
      }
    } catch (e) {
      debugPrint("ℹ️ Unable to fetch remote records (Offline mode): $e");
    }

    return [];
  }

  /// 3. Save User Profile: Save to SQLite first
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_canUseSQLite) {
      await DatabaseHelper.instance.saveUserProfile(profile);
      debugPrint("✅ Saved profile to local SQLite DB");
    }

    unawaited(_trySyncProfileToFirebase(profile));
  }

  Future<void> _trySyncProfileToFirebase(UserProfile profile) async {
    try {
      final uid = currentUserId;
      if (uid != null) {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(profile.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 4));
        debugPrint("☁️ Synced user profile to Firebase Cloud");
      }
    } catch (e) {
      debugPrint("ℹ️ Firebase profile sync skipped (Offline mode): $e");
    }
  }

  /// 4. Get User Profile: Read from SQLite first
  Future<UserProfile?> getUserProfile() async {
    final uid = currentUserId ?? "local_user";

    if (_canUseSQLite) {
      final localProfile = await DatabaseHelper.instance.getUserProfile(uid);
      if (localProfile != null) {
        return localProfile;
      }

      final allProfiles = await DatabaseHelper.instance.getAllUserProfiles();
      if (allProfiles.isNotEmpty) {
        return allProfiles.first;
      }
    }

    // Try Firebase if local is empty or on web
    try {
      final firebaseUid = currentUserId;
      if (firebaseUid != null) {
        final docSnapshot = await _firestore.collection('users').doc(firebaseUid).get().timeout(const Duration(seconds: 4));
        if (docSnapshot.exists && docSnapshot.data() != null) {
          final profile = UserProfile.fromMap(docSnapshot.data()!, docSnapshot.id);
          if (_canUseSQLite) {
            await DatabaseHelper.instance.saveUserProfile(profile);
          }
          return profile;
        }
      }
    } catch (e) {
      debugPrint("ℹ️ Unable to fetch remote user profile (Offline mode): $e");
    }

    return null;
  }
}
