// lib/repositories/match_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:amalay_user/models/user_profile.dart';

/// A profile shown in the Discover feed.
class DiscoveryCandidate {
  final String uid;
  final UserProfile profile;

  const DiscoveryCandidate({required this.uid, required this.profile});
}

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

/// Likes, passes, and matches.
///
/// Interim client-side implementation: mutual likes create the match document
/// directly. This moves into a Cloud Function trigger in the backend phase so
/// it cannot be spoofed.
class MatchRepository {
  static const String likesCollection = 'likes';
  static const String matchesCollection = 'matches';

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _likeDocId(String fromUid, String toUid) => '${fromUid}_$toUid';

  String _matchDocId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return sorted.join('_');
  }

  /// Records a like. Returns true when this like completed a mutual match.
  Future<bool> sendLike(String fromUid, String toUid) async {
    await _firestore
        .collection(likesCollection)
        .doc(_likeDocId(fromUid, toUid))
        .set({
          'from': fromUid,
          'to': toUid,
          'action': 'like',
          'createdAt': FieldValue.serverTimestamp(),
        });

    final reciprocal = await _firestore
        .collection(likesCollection)
        .doc(_likeDocId(toUid, fromUid))
        .get();

    final isMutual =
        reciprocal.exists && reciprocal.data()?['action'] == 'like';
    if (isMutual) {
      await _firestore
          .collection(matchesCollection)
          .doc(_matchDocId(fromUid, toUid))
          .set({
            'members': [fromUid, toUid]..sort(),
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
    return isMutual;
  }

  Future<void> sendPass(String fromUid, String toUid) async {
    await _firestore
        .collection(likesCollection)
        .doc(_likeDocId(fromUid, toUid))
        .set({
          'from': fromUid,
          'to': toUid,
          'action': 'pass',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  /// Uids the current user has already liked or passed on.
  Future<Set<String>> getActedOnUids(String uid) async {
    final snapshot = await _firestore
        .collection(likesCollection)
        .where('from', isEqualTo: uid)
        .get();
    return snapshot.docs
        .map((d) => (d.data()['to'] as String?) ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Profiles to show in Discover: complete, not premium-filtered, not self,
  /// not already acted on, and matching who the user is looking for.
  Future<List<DiscoveryCandidate>> getDiscoveryCandidates({
    required String currentUid,
    required List<String> lookingFor,
    int limit = 30,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('profileComplete', isEqualTo: true)
        .limit(limit * 2);

    if (lookingFor.isNotEmpty && lookingFor.length <= 10) {
      query = query.where('profile.gender', whereIn: lookingFor);
    }

    final actedOn = await getActedOnUids(currentUid);
    final snapshot = await query.get();

    final candidates = <DiscoveryCandidate>[];
    for (final doc in snapshot.docs) {
      if (doc.id == currentUid || actedOn.contains(doc.id)) continue;
      final profile = UserProfile.fromMap(
        (doc.data()['profile'] as Map?)?.cast<String, dynamic>(),
      );
      if (profile == null) continue;
      candidates.add(DiscoveryCandidate(uid: doc.id, profile: profile));
      if (candidates.length >= limit) break;
    }
    return candidates;
  }

  /// Streams the user's matches, newest first.
  Stream<List<MatchEntry>> watchMatches(String uid) {
    return _firestore
        .collection(matchesCollection)
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

  /// Fetches the display profile of another user (for match rows).
  Future<UserProfile?> getProfileOf(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserProfile.fromMap(
      (doc.data()?['profile'] as Map?)?.cast<String, dynamic>(),
    );
  }
}
