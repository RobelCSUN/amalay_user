// lib/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/services/geo/geo_utils.dart';
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
        'accountStatus': 'active',
        'isPremium': false,
        'blocked': <String>[],
      });
    }
  }

  /// Saves the completed onboarding profile.
  Future<void> saveProfile(String uid, UserProfile profile) async {
    await _userDoc(uid).set({
      'displayName': profile.firstName,
      'profile': profile.toMap(),
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stores the user's last known location for geo matching.
  Future<void> saveLocation(String uid, GeoPointData location) async {
    await _userDoc(uid).set({
      'location': location.toMap(),
      'locationUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Checks if the user's profile is complete.
  Future<bool> isProfileComplete(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data?['profileComplete'] == true;
  }

  /// The account lifecycle status ('active' unless changed server-side).
  Future<String> getAccountStatus(String uid) async {
    final doc = await _userDoc(uid).get();
    return (doc.data()?['accountStatus'] as String?) ?? 'active';
  }

  /// Reads the user's profile, or null if onboarding never finished.
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _userDoc(uid).get();
    return UserProfile.fromMap(
      (doc.data()?['profile'] as Map?)?.cast<String, dynamic>(),
    );
  }

  /// Reads the user's stored location, if any.
  Future<GeoPointData?> getLocation(String uid) async {
    final doc = await _userDoc(uid).get();
    return GeoPointData.fromMap(
      (doc.data()?['location'] as Map?)?.cast<String, dynamic>(),
    );
  }

  /// Reads the like quota for display. The server is the enforcement point;
  /// this only seeds the counter shown in the UI.
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

  /// Updates the last login timestamp.
  Future<void> touchLogin(String uid) async {
    await _userDoc(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
