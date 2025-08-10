// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../widgets/sign_in/google_sign_in_button.dart';
import '../../widgets/sign_in/phone_sign_in_button.dart';
import '../../widgets/sign_in/apple_sign_in_button.dart';
import '../auth/phone_auth_screen.dart'; // <- for phone flow screen

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
    } catch (e) {
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign-in failed')),
      );
    }
  }

  Future<void> _openPhoneAuth() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
    // If ok == true, Firebase authStateChanges() will emit and rebuild UI.
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _google.signOut();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Show buttons immediately; StreamBuilder will switch to signed-in UI if needed.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amalay - Login'),
        actions: [
          StreamBuilder<User?>(
            stream: _auth.authStateChanges(),
            builder: (context, snap) {
              final user = snap.data;
              if (user != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Sign out',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snap) {
          final user = snap.data;

          if (user != null) {
            // Signed-in UI
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Logged in as:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    user.displayName ?? user.email ?? 'User',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: _signOut,
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            );
          }

          // Not signed in (or still restoring) -> show buttons immediately
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GoogleSignInFullWidthButton(
                  width: 250,
                  height: 48,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 12),
                PhoneSignInFullWidthButton(
                  width: 250,
                  height: 48,
                  onPressed: _openPhoneAuth,
                ),
                const SizedBox(height: 12),
                AppleSignInFullWidthButton(
                  width: 250,
                  height: 48,
                  onPressed: _signInWithApple,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}