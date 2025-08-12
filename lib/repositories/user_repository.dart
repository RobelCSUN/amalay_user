// lib/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Create baseline user doc if missing.
  Future<void> ensureUserDoc(User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
      }, SetOptions(merge: true));
    } else {
      // keep it lightweight, don’t overwrite user’s edits
      await ref.set({
        'email': user.email,
        'photoURL': user.photoURL,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> touchLogin(String uid) async {
    await _users.doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isProfileComplete(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists) return false;
    return (snap.data()?['profileComplete'] as bool?) ?? false;
  }

  Future<void> markProfileComplete(String uid,
      {required String displayName}) async {
    await _users.doc(uid).set({
      'displayName': displayName,
      'profileComplete': true,
    }, SetOptions(merge: true));
  }
}