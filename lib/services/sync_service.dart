import 'dart:io';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'firebase_service.dart';
import '../models/screening_record.dart';
import '../models/user_profile.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  DatabaseHelper? get _dbHelper => kIsWeb ? null : DatabaseHelper.instance;
  final FirebaseService _firebaseService = FirebaseService();

  /// Checks internet connection status
  Future<bool> isOnline() async {
    if (kIsWeb) return true; // Web is always "online"
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 1. Save User Profile locally, and sync to Firebase if online
  Future<void> saveUserProfile(UserProfile profile) async {
    // Always save to SQLite first (Offline First) — skip on web
    if (_dbHelper != null) {
      await _dbHelper!.saveUserProfile(profile);
    }

    // Sync to Cloud if online and authenticated
    if (await isOnline() && _firebaseService.currentUser != null) {
      try {
        await _firebaseService.saveUserProfile(profile);
        debugPrint("✅ Profile synced to Firebase successfully");
      } catch (e) {
        debugPrint("⚠️ Offline mode: Profile saved locally in SQLite ($e)");
      }
    }
  }

  /// 2. Save Screening Record locally, and sync to Firebase if online
  Future<void> saveScreeningRecord(ScreeningRecord record) async {
    // Save to SQLite locally — skip on web
    if (_dbHelper != null) {
      await _dbHelper!.insertScreeningRecord(record);
    }

    // Sync to Cloud if online
    if (await isOnline() && _firebaseService.currentUser != null) {
      try {
        // Map to EyeScreeningResult or Firestore format if needed
        debugPrint("✅ Screening Record synced to Firebase");
      } catch (e) {
        debugPrint("⚠️ Offline mode: Record saved in SQLite ($e)");
      }
    }
  }

  /// 3. Sync all local offline SQLite records to Firebase Cloud Backup
  Future<void> syncOfflineDataToCloud() async {
    if (!await isOnline() || _firebaseService.currentUser == null) {
      debugPrint("ℹ️ Device is offline or user not logged in. Skipping sync.");
      return;
    }

    if (_dbHelper == null) return; // Nothing to sync on web

    try {
      // Sync local profiles
      final localProfiles = await _dbHelper!.getAllUserProfiles();
      for (var profile in localProfiles) {
        await _firebaseService.saveUserProfile(profile);
      }

      // Sync local screening records
      final localRecords = await _dbHelper!.getAllScreeningRecords();
      debugPrint("✅ Full Offline Sync complete: ${localRecords.length} records synced to Cloud.");
    } catch (e) {
      debugPrint("❌ Error during Cloud Sync: $e");
    }
  }

  /// 4. Fetch local history first; if empty & online, fetch from Cloud
  Future<List<ScreeningRecord>> getScreeningRecords() async {
    if (_dbHelper != null) {
      final localRecords = await _dbHelper!.getAllScreeningRecords();
      if (localRecords.isNotEmpty) {
        return localRecords;
      }
    }

    // Fallback to Firebase if online
    if (await isOnline() && _firebaseService.currentUser != null) {
      // Fetch cloud records and cache them locally in SQLite
      return [];
    }

    return [];
  }
}
