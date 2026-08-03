// lib/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/services/likes/like_quota.dart';

class UserRepository {
  // Single source of truth for users collection
  static const String usersCollection = 'users';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(usersCollection).doc(uid);

  /// Ensures that the user's document exists in Firestore.
  Future<void> ensureUserDoc(User user) async {
    final docRef = _userDoc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
        'isPremium': false,
        'likesToday': 0,
        'likesResetAt': null,
      });
    }
  }

  /// Saves the completed onboarding profile and marks the account ready to
  /// use the free tier.
  Future<void> saveProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set({
      'displayName': profile.firstName,
      'profile': profile.toMap(),
      'profileComplete': true,
      'isPremium': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Checks if the user's profile is complete.
  Future<bool> isProfileComplete(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data?['profileComplete'] == true;
  }

  /// Reads the user's profile, or null if onboarding never finished.
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    return UserProfile.fromMap(
      (doc.data()?['profile'] as Map?)?.cast<String, dynamic>(),
    );
  }

  /// Reads the current like quota state from the user doc.
  Future<LikeQuota> getLikeQuota(String uid) async {
    final doc = await _userDoc(uid).get();
    final data = doc.data();
    final resetAtRaw = data?['likesResetAt'];
    return LikeQuota(
      likesToday: (data?['likesToday'] as num?)?.toInt() ?? 0,
      resetAt: resetAtRaw is Timestamp ? resetAtRaw.toDate() : null,
    );
  }

  Future<bool> isPremium(String uid) async {
    final doc = await _userDoc(uid).get();
    return doc.data()?['isPremium'] == true;
  }

  /// Persists the like quota after a like is spent.
  Future<void> saveLikeQuota(String uid, LikeQuota quota) async {
    await _userDoc(uid).set({
      'likesToday': quota.likesToday,
      'likesResetAt': quota.resetAt == null
          ? null
          : Timestamp.fromDate(quota.resetAt!),
    }, SetOptions(merge: true));
  }

  /// Updates the last login timestamp.
  Future<void> touchLogin(String uid) async {
    await _userDoc(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
