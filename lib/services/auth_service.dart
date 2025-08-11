// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithGoogle() async {
    final user = await _google.signIn();
    if (user == null) return; // user canceled
    final auth = await user.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    await _auth.signInWithCredential(cred);
  }

  Future<void> signInWithApple() async {
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
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _google.signOut();
  }
}