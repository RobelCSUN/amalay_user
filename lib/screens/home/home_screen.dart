// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:amalay_user/services/auth/auth_service.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/auth/phone_auth_screen.dart';

import 'package:amalay_user/widgets/signed_in_card.dart';
import 'package:amalay_user/widgets/auth_card.dart';
import 'package:amalay_user/onboarding/create_profile_screen.dart'; // ← NEW

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSignUp = false; // copy-only toggle
  late final AuthService _authService;
  bool _pushedProfileFlow = false; // avoid double navigation

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  Future<void> _handleGoogle() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

    // 1) Auth only
    try {
      debugPrint('[Auth] Google sign-in: start');
      await _authService.signInWithGoogle();
      debugPrint('[Auth] Google sign-in: success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled') return;
      debugPrint('[Auth] Google sign-in ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
      return;
    } catch (e) {
      debugPrint('[Auth] Google sign-in ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google sign-in failed')));
      return;
    }

    // 2) Firestore best-effort
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final repo = UserRepository();
      await repo.ensureUserDoc(user);
      await repo.touchLogin(user.uid);
    } catch (e) {
      debugPrint('[Repo] ensure/touch failed (ignored): $e');
    }
  }

  Future<void> _handleApple() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

    try {
      debugPrint('[Auth] Apple sign-in: start');
      await _authService.signInWithApple();
      debugPrint('[Auth] Apple sign-in: success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled') return;
      debugPrint('[Auth] Apple sign-in ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Apple sign-in failed')));
      return;
    } catch (e) {
      debugPrint('[Auth] Apple sign-in ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Apple sign-in failed')));
      return;
    }

    // Firestore best-effort
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final repo = UserRepository();
      await repo.ensureUserDoc(user);
      await repo.touchLogin(user.uid);
    } catch (e) {
      debugPrint('[Repo] ensure/touch failed (ignored): $e');
    }
  }

  Future<void> _openPhoneAuth() async {
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
  }

  Future<void> _signOut() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    try {
      debugPrint('[Auth] signOut: start');
      await _authService.signOut();
      debugPrint('[Auth] signOut: done');
    } finally {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      _pushedProfileFlow = false; // reset navigation guard
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<User?>(
            stream: _authService.authStateChanges,
            builder: (context, snap) {
              final user = snap.data;

              // Signed out -> show auth buttons
              if (user == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  }
                });

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.40),
                    Center(
                      child: AuthCard(
                        isSignUp: _isSignUp,
                        onToggleCopy: () =>
                            setState(() => _isSignUp = !_isSignUp),
                        onGoogle: () {
                          _handleGoogle();
                        },
                        onPhone: () {
                          _openPhoneAuth();
                        },
                        onApple: () {
                          _handleApple();
                        },
                      ),
                    ),
                  ],
                );
              }

              // Signed in -> decide where to go based on profile completeness
              return FutureBuilder<bool>(
                future: UserRepository().isProfileComplete(user.uid),
                builder: (context, snap2) {
                  if (snap2.connectionState == ConnectionState.waiting) {
                    // Tiny loader while checking Firestore
                    return const Center(child: CircularProgressIndicator());
                  }

                  final complete = snap2.data == true;

                  if (!complete && !_pushedProfileFlow) {
                    // Navigate once to create profile
                    _pushedProfileFlow = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const CreateProfileScreen(),
                        ),
                      );
                    });
                    return const SizedBox.shrink();
                  }

                  // Profile complete -> show your signed-in card
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();
                  });
                  return Center(
                    child: SignedInCard(user: user, onSignOut: _signOut),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
