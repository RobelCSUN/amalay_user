// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/phone_auth_screen.dart';

import '../../widgets/signed_in_card.dart';
import '../../widgets/auth_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSignUp = false; // copy-only toggle (does not change auth logic)
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  Future<void> _handleGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> _handleApple() async {
    await _authService.signInWithApple();
  }

  Future<void> _openPhoneAuth() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background only; title + content live inside cards
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
                return Center(
                  child: SignedInCard(
                    user: user,
                    onSignOut: _signOut,
                  ),
                );
              }

              // Not signed in — show auth card at ~40% down the screen
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