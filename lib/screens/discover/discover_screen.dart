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
import 'package:amalay_user/widgets/match_celebration.dart';
import 'package:amalay_user/widgets/report_user_sheet.dart';
import 'package:amalay_user/widgets/swipe_card_stack.dart';

/// Discovery feed: swipeable profile cards with geo distance and the
/// server-enforced daily like limit.
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
  final _swipeController = SwipeCardController();

  List<DiscoveryCandidate> _candidates = [];
  int _index = 0;
  bool _loading = true;
  int _remainingLikes = LikeQuota.freeDailyLimit;
  bool _isPremium = false;
  GeoPointData? _myLocation;
  String _myName = '';
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
        _myName = profile?.firstName ?? '';
        _loading = false;
      });
    } catch (e) {
      debugPrint('[Discover] load failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load profiles.';
      });
    }
  }

  DiscoveryCandidate? _candidateAt(int index) =>
      index < _candidates.length ? _candidates[index] : null;

  bool _canSwipe(SwipeDirection direction) {
    if (direction == SwipeDirection.left) return true;
    if (_isPremium || _remainingLikes > 0) return true;
    _showLimitReached();
    return false;
  }

  void _onSwiped(SwipeDirection direction) {
    final candidate = _candidateAt(_index);
    if (candidate == null) return;

    setState(() => _index += 1);

    if (direction == SwipeDirection.right) {
      _sendLike(candidate);
    } else {
      _sendPass(candidate);
    }
  }

  Future<void> _sendLike(DiscoveryCandidate candidate) async {
    try {
      final result = await widget.matchRepository.sendLike(candidate.uid);
      if (!mounted) return;
      setState(() => _remainingLikes = result.remainingLikes);

      if (result.isMatch) {
        await showMatchCelebration(
          context,
          myName: _myName,
          matchName: candidate.profile.firstName,
        );
      }
    } on LikeLimitReachedException {
      if (!mounted) return;
      setState(() {
        _remainingLikes = 0;
        _index = (_index - 1).clamp(0, _candidates.length);
      });
      _showLimitReached();
    } catch (e) {
      debugPrint('[Discover] like failed: $e');
      if (!mounted) return;
      setState(() => _index = (_index - 1).clamp(0, _candidates.length));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send like. Try again.')),
      );
    }
  }

  Future<void> _sendPass(DiscoveryCandidate candidate) async {
    try {
      await widget.matchRepository.sendPass(candidate.uid);
    } catch (e) {
      // A failed pass is recoverable: the profile simply reappears later.
      debugPrint('[Discover] pass failed: $e');
    }
  }

  Future<void> _reportOrBlock() async {
    final uid = _uid;
    final candidate = _candidateAt(_index);
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
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("You're out of likes"),
        content: const Text(
          'Free members get ${LikeQuota.freeDailyLimit} likes per day and '
          'they reset at midnight. Amalay Premium with unlimited likes is '
          'coming soon.',
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
            child: Row(
              children: [
                Text(
                  'Discover',
                  style: AppTextStyles.heroTitle.copyWith(fontSize: 26),
                ),
                const Spacer(),
                _LikesPill(
                  isPremium: _isPremium,
                  remaining: _remainingLikes,
                ),
                IconButton(
                  onPressed: _loading ? null : _load,
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh, color: Colors.white54),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: _buildBody(),
            ),
          ),
          _ActionRow(
            enabled: !_loading && _candidateAt(_index) != null,
            onPass: () => _swipeController.swipe(SwipeDirection.left),
            onLike: () => _swipeController.swipe(SwipeDirection.right),
            onReport: _reportOrBlock,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        message: _error!,
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    final current = _candidateAt(_index);
    if (current == null) {
      return _EmptyState(
        icon: Icons.explore_outlined,
        message: "You've seen everyone nearby for now.\nCheck back later!",
        actionLabel: 'Refresh',
        onAction: _load,
      );
    }
    final next = _candidateAt(_index + 1);

    return SwipeCardStack(
      key: ValueKey(current.uid),
      controller: _swipeController,
      canSwipe: _canSwipe,
      onSwiped: _onSwiped,
      topCard: _ProfileCard(
        candidate: current,
        myLocation: _myLocation,
      ),
      behindCard: next == null
          ? null
          : _ProfileCard(candidate: next, myLocation: _myLocation),
    );
  }
}

class _LikesPill extends StatelessWidget {
  final bool isPremium;
  final int remaining;

  const _LikesPill({required this.isPremium, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(colors: AppColors.premiumGradient)
            : null,
        color: isPremium ? null : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceOutline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.favorite,
            size: 15,
            color: isPremium ? const Color(0xFF4A3211) : AppColors.accentRose,
          ),
          const SizedBox(width: 6),
          Text(
            isPremium ? 'Premium' : '$remaining left',
            style: TextStyle(
              color: isPremium ? const Color(0xFF4A3211) : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPass;
  final VoidCallback onLike;
  final VoidCallback onReport;

  const _ActionRow({
    required this.enabled,
    required this.onPass,
    required this.onLike,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleAction(
            size: 48,
            icon: Icons.flag_outlined,
            iconColor: Colors.white60,
            background: Colors.white.withValues(alpha: 0.07),
            semantics: 'Report or block',
            onTap: enabled ? onReport : null,
          ),
          const SizedBox(width: 20),
          _CircleAction(
            size: 62,
            icon: Icons.close_rounded,
            iconColor: AppColors.nopeRed,
            background: Colors.white.withValues(alpha: 0.09),
            semantics: 'Pass',
            onTap: enabled ? onPass : null,
          ),
          const SizedBox(width: 20),
          _CircleAction(
            size: 62,
            icon: Icons.favorite_rounded,
            iconColor: Colors.white,
            background: AppColors.accentRose,
            glow: AppColors.accentRose,
            semantics: 'Like',
            onTap: enabled ? onLike : null,
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color? glow;
  final String semantics;
  final VoidCallback? onTap;

  const _CircleAction({
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.semantics,
    required this.onTap,
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantics,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: glow == null
                ? null
                : [
                    BoxShadow(
                      color: glow!.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: background,
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, color: iconColor, size: size * 0.46),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: AppColors.surfaceOutline),
            ),
            child: Icon(icon, size: 42, color: Colors.white38),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.heroBody,
          ),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final DiscoveryCandidate candidate;
  final GeoPointData? myLocation;

  const _ProfileCard({required this.candidate, required this.myLocation});

  List<Color> get _coverGradient {
    final palette = AppColors.profileCoverGradients;
    return palette[candidate.uid.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile profile = candidate.profile;
    final age = profile.ageOn(DateTime.now());
    final distance = (myLocation != null && candidate.location != null)
        ? distanceKm(myLocation!, candidate.location!)
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(color: AppColors.surfaceCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover area (photo placeholder until the photos milestone).
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _coverGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          profile.firstName.isEmpty
                              ? '?'
                              : profile.firstName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.30),
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                      // Bottom scrim + identity
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 40, 20, 14),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x00000000), Color(0xB3000000)],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${profile.firstName}, $age',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 15,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      distance == null
                                          ? profile.city
                                          : '${profile.city} • '
                                                '${distanceLabel(distance)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Details area
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: profile.activities.take(6).map((activity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentRose.withValues(
                                alpha: 0.16,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.accentRose.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Text(
                              activity,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          profile.bio,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 14.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
