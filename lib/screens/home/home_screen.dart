// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/user_repository.dart';
import '../../services/phone_auth_screen.dart';

import '../../widgets/signed_in_card.dart';
import '../../widgets/auth_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSignUp = false; // copy-only toggle
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  Future<void> _handleGoogle() async {
    // clear any stale snackbars
    if (mounted) ScaffoldMessenger.of(context).clearSnackBars();

    // ---- STEP 1: Google Auth ONLY
    try {
      debugPrint('[Auth] Google sign-in: start');
      await _authService.signInWithGoogle();
      debugPrint('[Auth] Google sign-in: success');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled') {
        debugPrint('[Auth] Google sign-in: user canceled');
        return;
      }
      debugPrint('[Auth] Google sign-in ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
      return; // stop here; don’t run Firestore step
    } catch (e) {
      debugPrint('[Auth] Google sign-in ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
      return;
    }

    // ---- STEP 2: Firestore (best-effort; never show "Google failed")
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[Auth] Google sign-in succeeded but currentUser==null');
        return;
      }
      debugPrint('[Repo] ensureUserDoc + touchLogin for ${user.uid}');
      final repo = UserRepository();
      await repo.ensureUserDoc(user);
      await repo.touchLogin(user.uid);
      debugPrint('[Repo] user doc ok');
    } catch (e) {
      // Don’t confuse user: log only
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign-in failed')),
      );
      return;
    } catch (e) {
      debugPrint('[Auth] Apple sign-in ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign-in failed')),
      );
      return;
    }

    // best-effort Firestore
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

              if (user != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                  }
                });
                return Center(
                  child: SignedInCard(
                    user: user,
                    onSignOut: _signOut,
                  ),
                );
              }

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
                      onToggleCopy: () => setState(() => _isSignUp = !_isSignUp),
                      onGoogle: _handleGoogle,
                      onPhone: _openPhoneAuth,
                      onApple: _handleApple,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}