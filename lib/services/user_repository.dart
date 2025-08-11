// lib/services/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Ensure a baseline user document exists for this UID.
  /// Creates it only if missing.
  Future<void> ensureUserDoc(User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phone': user.phoneNumber,
      // App-specific baseline fields (you can expand these later)
      'photos': [],
      'gender': null, // 'male' | 'female'
      'ageVerified': false,
      'countryPreference': 'Both', // 'Ethiopian' | 'Eritrean' | 'Both'
      'religion': {'value': null, 'custom': null},
      'preferences': {
        'disappearingMessages': false,
        'distanceKm': 50,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update the lastLoginAt timestamp on each successful login.
  Future<void> touchLogin(String uid) async {
    await _users.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch the user document as a Map (or null if missing).
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    return snap.data();
  }

  /// Merge partial updates into the user document.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}