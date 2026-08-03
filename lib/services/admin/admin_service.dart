// lib/services/admin/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// A pending report as shown in the admin queue.
class ReportEntry {
  final String reportId;
  final String reporterUid;
  final String reportedUid;
  final String reason;
  final String? details;
  final String status;
  final DateTime? createdAt;

  const ReportEntry({
    required this.reportId,
    required this.reporterUid,
    required this.reportedUid,
    required this.reason,
    this.details,
    required this.status,
    this.createdAt,
  });
}

/// Admin moderation actions. All privileged operations run through Cloud
/// Functions and require admin custom claims; Firestore rules additionally
/// restrict report reads/updates to admins.
class AdminService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Stream<List<ReportEntry>> watchPendingReports() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final createdAtRaw = data['createdAt'];
            return ReportEntry(
              reportId: doc.id,
              reporterUid: (data['reporterUid'] as String?) ?? '',
              reportedUid: (data['reportedUid'] as String?) ?? '',
              reason: (data['reason'] as String?) ?? '',
              details: data['details'] as String?,
              status: (data['status'] as String?) ?? 'pending',
              createdAt: createdAtRaw is Timestamp
                  ? createdAtRaw.toDate()
                  : null,
            );
          }).toList(),
        );
  }

  Future<void> setAccountStatus(String targetUid, String status) async {
    await _functions.httpsCallable('adminSetAccountStatus').call({
      'targetUid': targetUid,
      'status': status,
    });
  }

  Future<void> markReportReviewed(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'reviewed',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> dismissReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).update({
      'status': 'dismissed',
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
