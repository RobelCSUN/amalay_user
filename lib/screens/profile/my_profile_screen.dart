// lib/screens/profile/my_profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:amalay_user/app/app_routes.dart';
import 'package:amalay_user/models/user_profile.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/account/account_lifecycle_service.dart';
import 'package:amalay_user/services/auth/auth_service.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_text_styles.dart';

class MyProfileScreen extends StatefulWidget {
  final AuthService authService;
  final UserRepository userRepository;
  final AccountLifecycleService accountLifecycleService;

  const MyProfileScreen({
    super.key,
    required this.authService,
    required this.userRepository,
    required this.accountLifecycleService,
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final profile = await widget.userRepository.getProfile(user.uid);
      final token = await user.getIdTokenResult();
      final claims = token.claims ?? const {};
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isAdmin =
            claims['admin'] == true || claims['support_admin'] == true;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[MyProfile] load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmLifecycleAction({
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await action();
      await widget.authService.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      debugPrint('[MyProfile] lifecycle action failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not complete that. You may need to sign in again first.',
          ),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign out failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final profile = _profile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My profile',
              style: AppTextStyles.heroTitle.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 16),
            if (profile != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: AppColors.premiumGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: AppColors.accentRose,
                      child: Text(
                        profile.firstName.isEmpty
                            ? '?'
                            : profile.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.firstName}, '
                          '${profile.ageOn(DateTime.now())}',
                          style: AppTextStyles.heroTitle.copyWith(
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              profile.city,
                              style: AppTextStyles.heroBody,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(1.4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.premiumGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: AppColors.premiumGradient,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Amalay Premium',
                            style: AppTextStyles.heroBody.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Free plan',
                              style: AppTextStyles.legal.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlimited likes, see who liked you, and more. '
                        'Weekly, monthly, and yearly plans — coming soon.',
                        style: AppTextStyles.legal.copyWith(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('About me', style: AppTextStyles.heroBody),
              const SizedBox(height: 8),
              Text(
                profile.bio,
                style: AppTextStyles.heroBody.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 20),
              Text('My activities', style: AppTextStyles.heroBody),
              const SizedBox(height: 8),
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
            ] else
              Text(
                'Could not load your profile.',
                style: AppTextStyles.heroBody,
              ),
            const SizedBox(height: 32),
            if (_isAdmin) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.admin),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentWarm,
                    side: const BorderSide(color: AppColors.accentWarm),
                  ),
                  icon: const Icon(Icons.shield_outlined),
                  label: const Text('Admin: review reports'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                ),
                child: const Text('Sign out'),
              ),
            ),
            const SizedBox(height: 24),
            Text('Account', style: AppTextStyles.heroBody),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _confirmLifecycleAction(
                title: 'Deactivate account?',
                message:
                    'Your profile will be hidden from everyone until you '
                    'sign back in and reactivate. Continue?',
                confirmLabel: 'Deactivate',
                action: widget.accountLifecycleService.deactivateMyAccount,
              ),
              child: const Text(
                'Deactivate my account',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => _confirmLifecycleAction(
                title: 'Delete account?',
                message:
                    'Your account will be permanently deleted after a 14-day '
                    'grace period. Signing back in during that time cancels '
                    'the deletion. Continue?',
                confirmLabel: 'Delete',
                action: widget.accountLifecycleService.requestAccountDeletion,
              ),
              child: const Text(
                'Delete my account',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
