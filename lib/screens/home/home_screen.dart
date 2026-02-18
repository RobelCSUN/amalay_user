import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:amalay_user/app/app_routes.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/auth/auth_service.dart';
import 'package:amalay_user/widgets/auth_card.dart';
import 'package:amalay_user/widgets/signed_in_card.dart';
import 'package:amalay_user/widgets/themed_background.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  final UserRepository userRepository;

  const HomeScreen({
    super.key,
    required this.authService,
    required this.userRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final UserRepository _userRepository;

  StreamSubscription<User?>? _authSub;
  User? _currentUser;
  bool _isResolvingSession = true;
  bool _isProfileComplete = false;
  bool _isProfileFlowActive = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService;
    _userRepository = widget.userRepository;

    _authSub = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (!mounted) return;

    if (user == null) {
      setState(() {
        _currentUser = null;
        _isResolvingSession = false;
        _isProfileComplete = false;
        _isProfileFlowActive = false;
      });
      return;
    }

    setState(() {
      _currentUser = user;
      _isResolvingSession = true;
      _isProfileComplete = false;
    });

    try {
      // Keep user document lifecycle consistent regardless of auth provider.
      await _userRepository.ensureUserDoc(user);
      await _userRepository.touchLogin(user.uid);
      final profileComplete = await _userRepository.isProfileComplete(user.uid);

      if (!mounted) return;
      if (_currentUser?.uid != user.uid) return;

      setState(() {
        _isProfileComplete = profileComplete;
        _isResolvingSession = false;
      });

      if (!profileComplete) {
        await _startProfileFlowIfNeeded();
      }
    } catch (e) {
      debugPrint('[HomeScreen] Session bootstrap failed: $e');
      if (!mounted) return;
      setState(() {
        _isResolvingSession = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your account. Retry.')),
      );
    }
  }

  Future<void> _handleGoogle() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

    try {
      debugPrint('[Auth] Google sign-in: start');
      final credential = await _authService.signInWithGoogle();
      final hasActiveUser = FirebaseAuth.instance.currentUser != null;
      if (credential == null && !hasActiveUser) {
        return; // user canceled
      }
      debugPrint('[Auth] Google sign-in: success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled') return;
      debugPrint('[Auth] Google sign-in ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
    } catch (e) {
      debugPrint('[Auth] Google sign-in ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
    }
  }

  Future<void> _handleApple() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

    try {
      debugPrint('[Auth] Apple sign-in: start');
      final credential = await _authService.signInWithApple();
      final hasActiveUser = FirebaseAuth.instance.currentUser != null;
      if (credential == null && !hasActiveUser) {
        return;
      }
      debugPrint('[Auth] Apple sign-in: success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled') return;
      debugPrint('[Auth] Apple sign-in ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Apple sign-in failed')));
    } catch (e) {
      debugPrint('[Auth] Apple sign-in ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Apple sign-in failed')));
    }
  }

  Future<void> _openPhoneAuth() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    await Navigator.pushNamed(context, AppRoutes.phoneAuth);
  }

  Future<void> _handleFacebook() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Facebook sign-in will be enabled in the next milestone.'),
      ),
    );
  }

  Future<void> _signOut() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('[Auth] signOut ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign out failed')));
    }
  }

  Future<void> _startProfileFlowIfNeeded() async {
    if (!mounted || _isProfileFlowActive || _currentUser == null) return;

    _isProfileFlowActive = true;

    final result = await Navigator.of(
      context,
    ).pushNamed<bool>(AppRoutes.createProfile);

    _isProfileFlowActive = false;

    if (!mounted) return;
    final user = _currentUser;
    if (user == null) return;

    if (result == true) {
      setState(() {
        _isProfileComplete = true;
      });
      return;
    }

    final profileComplete = await _userRepository.isProfileComplete(user.uid);
    if (!mounted) return;
    setState(() {
      _isProfileComplete = profileComplete;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        useHeroImage: true,
        isCreateMode: true,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isResolvingSession) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final user = _currentUser;
    if (user == null) {
      return LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: double.infinity,
          height: constraints.maxHeight,
          child: AuthCard(
            onGoogle: _handleGoogle,
            onPhone: _openPhoneAuth,
            onApple: _handleApple,
            onFacebook: _handleFacebook,
            fullHeightLayout: true,
          ),
        ),
      );
    }

    if (!_isProfileComplete) {
      return SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Preparing your profile...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isProfileFlowActive
                        ? null
                        : _startProfileFlowIfNeeded,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: SignedInCard(user: user, onSignOut: _signOut),
      ),
    );
  }
}
