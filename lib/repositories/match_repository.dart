// lib/repositories/match_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/services/geo/geo_utils.dart';

/// A profile shown in the Discover feed.
class DiscoveryCandidate {
  final String uid;
  final UserProfile profile;
  final GeoPointData? location;

  const DiscoveryCandidate({
    required this.uid,
    required this.profile,
    this.location,
  });
}

/// Result of a server-side like.
class LikeResult {
  final bool isMatch;

  /// Likes left today; -1 means unlimited (premium).
  final int remainingLikes;

  const LikeResult({required this.isMatch, required this.remainingLikes});
}

/// Thrown when the free-tier daily like limit is reached (server-enforced).
class LikeLimitReachedException implements Exception {}

/// A mutual match between the current user and another user.
class MatchEntry {
  final String matchId;
  final String otherUid;
  final DateTime? createdAt;

  const MatchEntry({
    required this.matchId,
    required this.otherUid,
    this.createdAt,
  });
}

/// Likes, passes, matches, and discovery.
///
/// All trust-sensitive writes (likes, matches, quota) go through Cloud
/// Functions so they cannot be spoofed by a modified client. Firestore rules
/// block direct writes to `likes` and `matches`.
class MatchRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  /// Sends a like via the `sendLike` callable.
  /// Throws [LikeLimitReachedException] when the daily free quota is spent.
  Future<LikeResult> sendLike(String toUid) async {
    try {
      final result = await _functions.httpsCallable('sendLike').call({
        'toUid': toUid,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return LikeResult(
        isMatch: data['isMatch'] == true,
        remainingLikes: (data['remainingLikes'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        throw LikeLimitReachedException();
      }
      rethrow;
    }
  }

  Future<void> sendPass(String toUid) async {
    await _functions.httpsCallable('sendPass').call({'toUid': toUid});
  }

  Future<void> unmatch(String otherUid) async {
    await _functions.httpsCallable('unmatch').call({'otherUid': otherUid});
  }

  /// Uids the current user has already liked or passed on.
  Future<Set<String>> getActedOnUids(String uid) async {
    final snapshot = await _firestore
        .collection('likes')
        .where('from', isEqualTo: uid)
        .get();
    return snapshot.docs
        .map((d) => (d.data()['to'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Profiles to show in Discover: active + complete accounts matching who
  /// the user is looking for, excluding self, blocked users, and profiles
  /// already acted on. Sorted by distance when GPS is available.
  Future<List<DiscoveryCandidate>> getDiscoveryCandidates({
    required String currentUid,
    required List<String> lookingFor,
    required Set<String> blockedUids,
    GeoPointData? myLocation,
    int limit = 30,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('profileComplete', isEqualTo: true)
        .where('accountStatus', isEqualTo: 'active')
        .limit(limit * 2);

    if (lookingFor.isNotEmpty && lookingFor.length <= 10) {
      query = query.where('profile.gender', whereIn: lookingFor);
    }

    final actedOn = await getActedOnUids(currentUid);
    final snapshot = await query.get();

    final candidates = <DiscoveryCandidate>[];
    for (final doc in snapshot.docs) {
      if (doc.id == currentUid ||
          actedOn.contains(doc.id) ||
          blockedUids.contains(doc.id)) {
        continue;
      }
      final profile = UserProfile.fromMap(
        (doc.data()['profile'] as Map?)?.cast<String, dynamic>(),
      );
      if (profile == null) continue;
      candidates.add(
        DiscoveryCandidate(
          uid: doc.id,
          profile: profile,
          location: GeoPointData.fromMap(
            (doc.data()['location'] as Map?)?.cast<String, dynamic>(),
          ),
        ),
      );
      if (candidates.length >= limit) break;
    }

    if (myLocation != null) {
      candidates.sort((a, b) {
        final da = a.location == null
            ? double.infinity
            : distanceKm(myLocation, a.location!);
        final db = b.location == null
            ? double.infinity
            : distanceKm(myLocation, b.location!);
        return da.compareTo(db);
      });
    }
    return candidates;
  }

  /// Streams the user's matches, newest first.
  Stream<List<MatchEntry>> watchMatches(String uid) {
    return _firestore
        .collection('matches')
        .where('members', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final entries = snapshot.docs.map((doc) {
            final members = List<String>.from(
              doc.data()['members'] as List? ?? const [],
            );
            final other = members.firstWhere(
              (m) => m != uid,
              orElse: () => '',
            );
            final createdAtRaw = doc.data()['createdAt'];
            return MatchEntry(
              matchId: doc.id,
              otherUid: other,
              createdAt: createdAtRaw is Timestamp
                  ? createdAtRaw.toDate()
                  : null,
            );
          }).toList();
          entries.sort((a, b) {
            final at = a.createdAt ?? DateTime(2000);
            final bt = b.createdAt ?? DateTime(2000);
            return bt.compareTo(at);
          });
          return entries;
        });
  }

  /// Fetches the display profile of another user. Returns null when the
  /// profile is unavailable (e.g. account deactivated -> read denied).
  Future<UserProfile?> getProfileOf(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return UserProfile.fromMap(
        (doc.data()?['profile'] as Map?)?.cast<String, dynamic>(),
      );
    } catch (_) {
      return null;
    }
  }
}
