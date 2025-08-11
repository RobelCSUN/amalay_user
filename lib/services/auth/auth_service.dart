import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google.
  /// - Tries silent sign-in first (no UI).
  /// - If user cancels the interactive sheet, returns null (no error).
  /// - If already signed in, returns null (no-op).
  Future<UserCredential?> signInWithGoogle() async {
    if (_auth.currentUser != null) return null; // already signed in

    // 1) Try silent sign-in (restores previous session without UI)
    try {
      final silent = await _google.signInSilently(suppressErrors: true);
      if (silent != null) {
        final auth = await silent.authentication;
        final cred = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        return await _auth.signInWithCredential(cred);
      }
    } catch (_) {
      // Ignore silent sign-in errors; we’ll try the interactive flow next.
    }

    // 2) Interactive sign-in
    final GoogleSignInAccount? user = await _google.signIn();
    if (user == null) {
      // User cancelled -> NOT an error
      return null;
    }

    final GoogleSignInAuthentication auth = await user.authentication;
    final OAuthCredential cred = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(cred);
  }

  Future<UserCredential?> signInWithApple() async {
    if (!(Platform.isIOS || Platform.isMacOS)) {
      throw FirebaseAuthException(
        code: 'unsupported-platform',
        message: 'Sign in with Apple is only available on Apple platforms.',
      );
    }
    if (_auth.currentUser != null) return null;

    final appleId = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );

    final OAuthCredential cred = OAuthProvider('apple.com').credential(
      idToken: appleId.identityToken,
      accessToken: appleId.authorizationCode,
    );
    return _auth.signInWithCredential(cred);
  }

  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}