// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../widgets/sign_in/google_sign_in_button.dart';
import '../../widgets/sign_in/phone_sign_in_button.dart';
import '../../widgets/sign_in/apple_sign_in_button.dart';
import '../auth/phone_auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      final user = await _google.signIn();
      if (user == null) return; // user canceled
      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await _auth.signInWithCredential(cred);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final c = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final cred = OAuthProvider("apple.com").credential(
        idToken: c.identityToken,
        accessToken: c.authorizationCode,
      );
      await _auth.signInWithCredential(cred);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign-in failed')),
      );
    }
  }

  Future<void> _openPhoneAuth() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _google.signOut();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar — title lives inside the card
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Warm orange gradient background
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<User?>(
            stream: _auth.authStateChanges(),
            builder: (context, snap) {
              final user = snap.data;

              if (user != null) {
                // Signed-in UI
                return Center(
                  child: Container(
                    // ---- SIZE TWEAK: adjust maxWidth or padding to change card size
                    constraints: const BoxConstraints(maxWidth: 420),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Amalay',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Just a swipe away from turning quiet weekends into unforgettable moments together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          user.displayName ?? user.email ?? 'User',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 280,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _signOut,
                            child: const Text('Sign Out'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Not signed in — show the card with buttons
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.40),

                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Amalay',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Just a swipe away from turning quiet weekends into unforgettable moments together.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Buttons (logic unchanged)
                          GoogleSignInFullWidthButton(
                            width: double.infinity,
                            height: 48,
                            onPressed: _signInWithGoogle,
                          ),
                          const SizedBox(height: 12),
                          PhoneSignInFullWidthButton(
                            width: double.infinity,
                            height: 48,
                            onPressed: _openPhoneAuth,
                          ),
                          const SizedBox(height: 12),
                          AppleSignInFullWidthButton(
                            width: double.infinity,
                            height: 48,
                            onPressed: _signInWithApple,
                          ),
                        ],
                      ),
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