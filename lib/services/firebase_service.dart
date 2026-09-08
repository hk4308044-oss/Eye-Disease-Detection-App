import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:flutter/foundation.dart';
import '../models/screening_record.dart';
import '../models/eye_screening_result.dart';
import '../models/user_profile.dart';
import 'dart:io';

class FirebaseService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;
  final google_sign_in.GoogleSignIn _googleSignIn = google_sign_in.GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  /// Translates common Firebase/Network errors to friendly messages
  String _getFriendlyError(dynamic e) {
    if (e is SocketException || e.toString().contains('network-request-failed')) {
      return "You appear to be offline. Please check your connection and try again.";
    }
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return "No account found with this email.";
        case 'wrong-password': return "Incorrect password. Please try again.";
        case 'email-already-in-use': return "This email is already registered. Try signing in instead.";
        case 'weak-password': return "Please choose a stronger password.";
        case 'invalid-email': return "Please enter a valid email address.";
      }
    }
    if (e is FirebaseException) {
      return "Firebase Error: ${e.message ?? e.code}";
    }
    return "An unexpected error occurred: ${e.toString()}";
  }

  /// Signs in a user with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Creates a new user with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Send verification email automatically on signup
      try {
        final user = credential.user;
        if (user == null) {
          throw Exception("No authenticated Firebase user found.");
        }
        debugPrint("UID: ${user.uid}");
        debugPrint("EMAIL: ${user.email}");
        debugPrint("VERIFIED BEFORE: ${user.emailVerified}");

        await user.sendEmailVerification();

        debugPrint("EMAIL VERIFICATION REQUEST COMPLETED SUCCESSFULLY");
      } on FirebaseAuthException catch (e) {
        debugPrint("FIREBASE ERROR CODE: ${e.code}");
        debugPrint("FIREBASE ERROR MESSAGE: ${e.message}");
      } catch (e) {
        debugPrint("UNKNOWN ERROR: $e");
      }
      return credential;
    } catch (e) {
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Initiates Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final google_sign_in.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in flow
      }

      final google_sign_in.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Sends an email verification link
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception("No authenticated Firebase user found.");
      }

      debugPrint("UID: ${user.uid}");
      debugPrint("EMAIL: ${user.email}");
      debugPrint("VERIFIED BEFORE: ${user.emailVerified}");

      await user.sendEmailVerification();

      debugPrint("EMAIL VERIFICATION REQUEST COMPLETED SUCCESSFULLY");
    } on FirebaseAuthException catch (e) {
      debugPrint("FIREBASE ERROR CODE: ${e.code}");
      debugPrint("FIREBASE ERROR MESSAGE: ${e.message}");
      if (e.code == 'too-many-requests') {
         throw Exception("Too many requests. Please wait a moment before trying again.");
      }
      throw Exception("Failed to send verification email. Firebase error: ${e.message}");
    } catch (e) {
      debugPrint("UNKNOWN ERROR: $e");
      throw Exception("Failed to send verification email: $e");
    }
  }

  /// Checks if the current user's email is verified
  Future<bool> checkEmailVerified() async {
    final user = currentUser;
    if (user != null) {
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    }
    return false;
  }

  /// Sends a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Saves or updates the UserProfile
  Future<void> saveUserProfile(UserProfile profile) async {
    final user = currentUser;
    if (user == null) throw Exception("User not authenticated");
    
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': profile.name,
        'age': profile.age,
        'dateOfBirth': profile.dateOfBirth,
        'gender': profile.gender,
        'wearsGlasses': profile.wearsGlasses,
        'familyHistory': profile.familyHistory,
        'averageScreenTimeHours': profile.averageScreenTimeHours,
        'commonSymptoms': profile.commonSymptoms,
        'eyeHealthScore': profile.eyeHealthScore,
        'streakDays': profile.streakDays,
        'role': profile.role,
        'preferredLanguage': profile.preferredLanguage,
        'userGoals': profile.userGoals,
        'hasConsented': profile.hasConsented,
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Fetches the UserProfile
  Future<UserProfile?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return null;
      
      final data = doc.data()!;
      return UserProfile(
        id: data['id'] ?? user.uid,
        name: data['name'] ?? '',
        age: data['age'] ?? 0,
        dateOfBirth: data['dateOfBirth'],
        gender: data['gender'] ?? 'Unknown',
        wearsGlasses: data['wearsGlasses'] ?? false,
        familyHistory: data['familyHistory'] ?? false,
        averageScreenTimeHours: data['averageScreenTimeHours'] ?? 0,
        commonSymptoms: List<String>.from(data['commonSymptoms'] ?? []),
        eyeHealthScore: data['eyeHealthScore'] ?? 85,
        streakDays: data['streakDays'] ?? 0,
        role: data['role'] ?? 'user',
        preferredLanguage: data['preferredLanguage'] ?? 'en',
        userGoals: List<String>.from(data['userGoals'] ?? []),
        hasConsented: data['hasConsented'] ?? false,
      );
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      return null;
    }
  }

  /// Saves a new AI eye screening result to Firestore
  Future<void> saveScreeningResult(EyeScreeningResult result) async {
    final user = currentUser;
    if (user == null) {
      debugPrint("Warning: User not logged in, cannot save screening result.");
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('screenings')
          .doc(result.id)
          .set(result.toMap());
    } catch (e) {
      debugPrint('Error saving screening result: $e');
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Deletes a specific image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Gets the user's images from Firebase Storage
  Future<List<String>> getUserImages() async {
    final user = currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      final listResult = await _storage.ref('users/${user.uid}/images').listAll();
      final urls = await Future.wait(listResult.items.map((ref) => ref.getDownloadURL()));
      return urls;
    } catch (e) {
      debugPrint('Error getting user images: $e');
      return [];
    }
  }

  /// Deletes all screening records for the authenticated user
  Future<void> deleteScreeningHistory() async {
    final user = currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      final batch = _firestore.batch();
      final snapshots = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('screenings')
          .get();
      
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting screening history: $e');
      throw Exception(_getFriendlyError(e));
    }
  }

  /// Deletes the user account and all associated data
  Future<void> deleteAccountAndData() async {
    final user = currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      // 1. Delete all Firestore data (Screenings)
      await deleteScreeningHistory();

      // Delete user profile doc if exists
      await _firestore.collection('users').doc(user.uid).delete();

      // 2. Delete all Storage data (Images)
      try {
        final listResult = await _storage.ref('users/${user.uid}/images').listAll();
        for (var item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        debugPrint('Error deleting user storage files: $e');
      }

      // 3. Delete the Auth account
      await user.delete();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      throw Exception(_getFriendlyError(e));
    }
  }
}
