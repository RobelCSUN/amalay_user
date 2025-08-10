// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../widgets/sign_in/google_sign_in_button.dart';
import '../../widgets/sign_in/phone_sign_in_button.dart';
import '../../widgets/sign_in/apple_sign_in_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // user canceled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed')),
      );
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauth = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await _auth.signInWithCredential(oauth);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign-in failed')),
      );
    }
  }

  Future<void> _signInWithPhone() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone sign-in coming next')),
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amalay - Login'),
        actions: [
          StreamBuilder<User?>(
            stream: _auth.authStateChanges(),
            builder: (context, snap) {
              if (snap.data != null) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
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
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snap.data;

          if (user != null) {
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

          // Not signed in -> show 3 buttons immediately
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
                  onPressed: _signInWithPhone,
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