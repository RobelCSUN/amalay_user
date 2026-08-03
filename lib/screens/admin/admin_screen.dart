// lib/screens/admin/admin_screen.dart
import 'package:flutter/material.dart';

import 'package:amalay_user/services/admin/admin_service.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_text_styles.dart';

/// Admin moderation queue: pending reports with deactivate / reactivate /
/// dismiss actions. Only reachable for accounts with admin custom claims;
/// Firestore rules block the underlying reads for everyone else.
class AdminScreen extends StatefulWidget {
  final AdminService adminService;

  const AdminScreen({super.key, required this.adminService});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Future<void> _run(
    BuildContext context,
    String successMessage,
    Future<void> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      debugPrint('[Admin] action failed: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Action failed. Check your access.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF241614),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E1B18),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Report queue',
          style: AppTextStyles.heroTitle.copyWith(fontSize: 20),
        ),
      ),
      body: StreamBuilder<List<ReportEntry>>(
        stream: widget.adminService.watchPendingReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load reports.\nAdmin access required.',
                textAlign: TextAlign.center,
                style: AppTextStyles.heroBody,
              ),
            );
          }
          final reports = snapshot.data ?? const [];
          if (reports.isEmpty) {
            return Center(
              child: Text(
                'No pending reports. All clear!',
                style: AppTextStyles.heroBody,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.reason,
                      style: AppTextStyles.heroBody.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reported: ${report.reportedUid}',
                      style: AppTextStyles.legal.copyWith(fontSize: 12),
                    ),
                    if (report.details != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        report.details!,
                        style: AppTextStyles.heroBody.copyWith(fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _actionChip(
                          context,
                          label: 'Deactivate user',
                          color: Colors.redAccent,
                          onTap: () => _run(
                            context,
                            'User deactivated.',
                            () async {
                              await widget.adminService.setAccountStatus(
                                report.reportedUid,
                                'deactivated',
                              );
                              await widget.adminService.markReportReviewed(
                                report.reportId,
                              );
                            },
                          ),
                        ),
                        _actionChip(
                          context,
                          label: 'Reactivate user',
                          color: AppColors.accentWarm,
                          onTap: () => _run(
                            context,
                            'User reactivated.',
                            () => widget.adminService.setAccountStatus(
                              report.reportedUid,
                              'active',
                            ),
                          ),
                        ),
                        _actionChip(
                          context,
                          label: 'Dismiss report',
                          color: Colors.white54,
                          onTap: () => _run(
                            context,
                            'Report dismissed.',
                            () => widget.adminService.dismissReport(
                              report.reportId,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(label, style: TextStyle(color: color, fontSize: 13)),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      onPressed: onTap,
    );
  }
}
