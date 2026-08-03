// lib/screens/discover/discover_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/repositories/match_repository.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/geo/geo_utils.dart';
import 'package:amalay_user/services/geo/location_service.dart';
import 'package:amalay_user/services/likes/like_quota.dart';
import 'package:amalay_user/services/safety/safety_service.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_text_styles.dart';
import 'package:amalay_user/widgets/report_user_sheet.dart';

/// Free-tier discovery feed: profile cards with like/pass, geo distance,
/// and the server-enforced daily like limit.
class DiscoverScreen extends StatefulWidget {
  final UserRepository userRepository;
  final MatchRepository matchRepository;
  final SafetyService safetyService;
  final LocationService locationService;

  const DiscoverScreen({
    super.key,
    required this.userRepository,
    required this.matchRepository,
    required this.safetyService,
    required this.locationService,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<DiscoveryCandidate> _candidates = [];
  int _index = 0;
  bool _loading = true;
  bool _acting = false;
  int _remainingLikes = LikeQuota.freeDailyLimit;
  bool _isPremium = false;
  GeoPointData? _myLocation;
  String? _error;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await widget.userRepository.getProfile(uid);
      final quota = await widget.userRepository.getLikeQuota(uid);
      final premium = await widget.userRepository.isPremium(uid);
      final blocked = await widget.safetyService.getBlockedUids(uid);

      // Refresh GPS in the background of the feed load; stored location is
      // the fallback when permission is denied.
      var myLocation = await widget.locationService.getCurrentLocation();
      if (myLocation != null) {
        await widget.userRepository.saveLocation(uid, myLocation);
      } else {
        myLocation = await widget.userRepository.getLocation(uid);
      }

      final candidates = await widget.matchRepository.getDiscoveryCandidates(
        currentUid: uid,
        lookingFor: profile?.lookingFor ?? const [],
        blockedUids: blocked,
        myLocation: myLocation,
      );

      if (!mounted) return;
      setState(() {
        _candidates = candidates;
        _index = 0;
        _remainingLikes = quota.remaining(DateTime.now(), isPremium: premium);
        _isPremium = premium;
        _myLocation = myLocation;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[Discover] load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load profiles. Pull to retry.';
      });
    }
  }

  DiscoveryCandidate? get _current =>
      _index < _candidates.length ? _candidates[_index] : null;

  Future<void> _like() async {
    final candidate = _current;
    if (candidate == null || _acting) return;

    setState(() => _acting = true);
    try {
      final result = await widget.matchRepository.sendLike(candidate.uid);

      if (!mounted) return;
      setState(() {
        _remainingLikes = result.remainingLikes;
        _index += 1;
      });

      if (result.isMatch) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "It's a match with ${candidate.profile.firstName}!",
            ),
            backgroundColor: AppColors.accentRose,
          ),
        );
      }
    } on LikeLimitReachedException {
      if (mounted) _showLimitReached();
    } catch (e) {
      debugPrint('[Discover] like failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send like. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _pass() async {
    final candidate = _current;
    if (candidate == null || _acting) return;

    setState(() => _acting = true);
    try {
      await widget.matchRepository.sendPass(candidate.uid);
      if (!mounted) return;
      setState(() => _index += 1);
    } catch (e) {
      debugPrint('[Discover] pass failed: $e');
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _reportOrBlock() async {
    final uid = _uid;
    final candidate = _current;
    if (uid == null || candidate == null) return;

    final action = await showReportUserSheet(
      context,
      userName: candidate.profile.firstName,
    );
    if (action == null || !mounted) return;

    try {
      if (action.block) {
        await widget.safetyService.blockUser(
          uid: uid,
          blockedUid: candidate.uid,
        );
      }
      if (action.reason != null) {
        await widget.safetyService.reportUser(
          reporterUid: uid,
          reportedUid: candidate.uid,
          reason: action.reason!,
          details: action.details,
        );
      }
      if (!mounted) return;
      setState(() => _index += 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action.block
                ? '${candidate.profile.firstName} has been blocked.'
                : 'Report submitted. Thank you for keeping Amalay safe.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('[Discover] report/block failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not complete that. Try again.')),
        );
      }
    }
  }

  void _showLimitReached() {
    setState(() => _remainingLikes = 0);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("You're out of likes for today"),
        content: const Text(
          'Free members get ${LikeQuota.freeDailyLimit} likes per day. '
          'Your likes reset at midnight. Amalay Premium with unlimited '
          'likes is coming soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discover',
                      style: AppTextStyles.heroTitle.copyWith(fontSize: 26),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _isPremium
                            ? 'Premium'
                            : '$_remainingLikes likes left today',
                        style: AppTextStyles.legal.copyWith(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: AppTextStyles.heroBody),
      );
    }
    final candidate = _current;
    if (candidate == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_outlined, size: 56, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              "You've seen everyone nearby for now.\nCheck back later!",
              textAlign: TextAlign.center,
              style: AppTextStyles.heroBody,
            ),
          ],
        ),
      );
    }
    return _ProfileCard(
      candidate: candidate,
      myLocation: _myLocation,
      acting: _acting,
      onLike: _like,
      onPass: _pass,
      onReport: _reportOrBlock,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final DiscoveryCandidate candidate;
  final GeoPointData? myLocation;
  final bool acting;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onReport;

  const _ProfileCard({
    required this.candidate,
    required this.myLocation,
    required this.acting,
    required this.onLike,
    required this.onPass,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final UserProfile profile = candidate.profile;
    final age = profile.ageOn(DateTime.now());
    final distance = (myLocation != null && candidate.location != null)
        ? distanceKm(myLocation!, candidate.location!)
        : null;

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B221D), Color(0xFF7B4C3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.panelBorder),
            ),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.accentRose,
                        child: Text(
                          profile.firstName.isEmpty
                              ? '?'
                              : profile.firstName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onReport,
                        tooltip: 'Report or block',
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${profile.firstName}, $age',
                    style: AppTextStyles.heroTitle.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distance == null
                            ? profile.city
                            : '${profile.city} • ${distanceLabel(distance)}',
                        style: AppTextStyles.heroBody,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.activities.map((activity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          activity,
                          style: AppTextStyles.legal.copyWith(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.bio,
                    style: AppTextStyles.heroBody.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: Icons.close,
              color: Colors.white,
              background: Colors.white12,
              semantics: 'Pass',
              onTap: acting ? null : onPass,
            ),
            const SizedBox(width: 32),
            _ActionButton(
              icon: Icons.favorite,
              color: Colors.white,
              background: AppColors.accentRose,
              semantics: 'Like',
              onTap: acting ? null : onLike,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String semantics;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.semantics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(icon, color: color, size: 30),
          ),
        ),
      ),
    );
  }
}
