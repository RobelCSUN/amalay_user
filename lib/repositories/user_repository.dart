// lib/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  // 🔹 Single source of truth for users collection
  static const String usersCollection = 'users';

  final _firestore = FirebaseFirestore.instance;

  /// Ensures that the user's document exists in Firestore.
  Future<void> ensureUserDoc(User user) async {
    final docRef = _firestore.collection(usersCollection).doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
      });
    }
  }

  /// Marks the user profile as complete with optional display name.
  Future<void> markProfileComplete(String uid, {String? displayName}) async {
    final updateData = {
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null && displayName.trim().isNotEmpty) {
      updateData['displayName'] = displayName.trim();
    }

    await _firestore.collection(usersCollection).doc(uid).update(updateData);
  }

  /// Checks if the user's profile is complete.
  Future<bool> isProfileComplete(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data?['profileComplete'] == true;
  }

  /// Updates the last login timestamp.
  Future<void> touchLogin(String uid) async {
    await _firestore.collection(usersCollection).doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
}
