// lib/widgets/report_user_sheet.dart
import 'package:flutter/material.dart';

import 'package:amalay_user/services/safety/safety_service.dart';
import 'package:amalay_user/theme/app_colors.dart';

/// What the user chose in the report/block sheet.
class ReportAction {
  /// Selected report reason, or null if the user only blocked.
  final String? reason;
  final String? details;
  final bool block;

  const ReportAction({this.reason, this.details, required this.block});
}

/// Bottom sheet offering report reasons and a block option.
/// Resolves to null when dismissed.
Future<ReportAction?> showReportUserSheet(
  BuildContext context, {
  required String userName,
}) {
  return showModalBottomSheet<ReportAction>(
    context: context,
    backgroundColor: const Color(0xFF2E1B18),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) => _ReportSheet(userName: userName),
  );
}

class _ReportSheet extends StatefulWidget {
  final String userName;

  const _ReportSheet({required this.userName});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _reason;
  bool _alsoBlock = true;
  final _detailsCtrl = TextEditingController();

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report ${widget.userName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your report is anonymous. Accounts with repeated reports are '
            'deactivated automatically pending review.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _reason,
            onChanged: (value) => setState(() => _reason = value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final reason in kReportReasons)
                  RadioListTile<String>(
                    value: reason,
                    title: Text(
                      reason,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    activeColor: AppColors.accentRose,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsCtrl,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Details (optional)',
              labelStyle: TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _alsoBlock,
            onChanged: (value) => setState(() => _alsoBlock = value),
            title: const Text(
              'Also block this user',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            activeThumbColor: AppColors.accentRose,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(
                    const ReportAction(block: true),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  child: const Text('Just block'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _reason == null
                      ? null
                      : () => Navigator.of(context).pop(
                            ReportAction(
                              reason: _reason,
                              details: _detailsCtrl.text,
                              block: _alsoBlock,
                            ),
                          ),
                  child: const Text('Submit report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
