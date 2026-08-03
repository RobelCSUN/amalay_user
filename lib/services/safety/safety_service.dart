// lib/services/safety/safety_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Reasons shown in the report sheet.
const List<String> kReportReasons = [
  'Fake profile or scam',
  'Inappropriate photos or bio',
  'Harassment or abusive behavior',
  'Underage user',
  'Other',
];

/// Reporting and blocking. Reports feed the auto-moderation threshold in
/// Cloud Functions; blocks live on the user's own doc and filter discovery
/// and matches.
class SafetyService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> reportUser({
    required String reporterUid,
    required String reportedUid,
    required String reason,
    String? details,
  }) async {
    await _firestore.collection('reports').add({
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reason': reason,
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> blockUser({
    required String uid,
    required String blockedUid,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'blocked': FieldValue.arrayUnion([blockedUid]),
    }, SetOptions(merge: true));
  }

  Future<Set<String>> getBlockedUids(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return Set<String>.from(doc.data()?['blocked'] as List? ?? const []);
  }
}
