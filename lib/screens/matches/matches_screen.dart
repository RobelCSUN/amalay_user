// lib/screens/matches/matches_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/repositories/match_repository.dart';
import 'package:amalay_user/services/safety/safety_service.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_text_styles.dart';
import 'package:amalay_user/widgets/report_user_sheet.dart';

class MatchesScreen extends StatelessWidget {
  final MatchRepository matchRepository;
  final SafetyService safetyService;

  const MatchesScreen({
    super.key,
    required this.matchRepository,
    required this.safetyService,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Matches',
              style: AppTextStyles.heroTitle.copyWith(fontSize: 26),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MatchEntry>>(
              stream: matchRepository.watchMatches(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final matches = snapshot.data ?? const [];
                if (matches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 56,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No matches yet.\nKeep discovering!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heroBody,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _MatchTile(
                      currentUid: uid,
                      match: matches[index],
                      matchRepository: matchRepository,
                      safetyService: safetyService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  final String currentUid;
  final MatchEntry match;
  final MatchRepository matchRepository;
  final SafetyService safetyService;

  const _MatchTile({
    required this.currentUid,
    required this.match,
    required this.matchRepository,
    required this.safetyService,
  });

  Future<void> _onMenuAction(BuildContext context, String action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      switch (action) {
        case 'unmatch':
          await matchRepository.unmatch(match.otherUid);
          messenger.showSnackBar(
            const SnackBar(content: Text('Unmatched.')),
          );
        case 'report':
          final profile = await matchRepository.getProfileOf(match.otherUid);
          if (!context.mounted) return;
          final result = await showReportUserSheet(
            context,
            userName: profile?.firstName ?? 'this user',
          );
          if (result == null) return;
          if (result.block) {
            await safetyService.blockUser(
              uid: currentUid,
              blockedUid: match.otherUid,
            );
            await matchRepository.unmatch(match.otherUid);
          }
          if (result.reason != null) {
            await safetyService.reportUser(
              reporterUid: currentUid,
              reportedUid: match.otherUid,
              reason: result.reason!,
              details: result.details,
            );
          }
          messenger.showSnackBar(
            const SnackBar(content: Text('Thank you. Action completed.')),
          );
      }
    } catch (e) {
      debugPrint('[Matches] $action failed: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not complete that. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: matchRepository.getProfileOf(match.otherUid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final name = profile?.firstName ?? '...';
        final subtitle = profile == null
            ? ''
            : '${profile.city} • ${profile.activities.take(3).join(', ')}';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentRose,
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: Text(
              name,
              style: AppTextStyles.heroBody.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: subtitle.isEmpty
                ? null
                : Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.legal.copyWith(fontSize: 13),
                  ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: const Color(0xFF2E1B18),
              onSelected: (action) => _onMenuAction(context, action),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'unmatch',
                  child: Text(
                    'Unmatch',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: Text(
                    'Report or block',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat is coming in the next milestone.'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
