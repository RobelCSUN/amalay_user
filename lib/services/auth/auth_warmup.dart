import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthWarmup {
  static final GoogleSignIn _gsi = GoogleSignIn(); // same config you use in app
  static bool? _appleAvailable;
  static bool _didRun = false;

  static bool? get appleAvailable => _appleAvailable;

  /// Call once at app start. Runs quick, returns when all pre-warm tasks finish or time out.
  static Future<void> run({Duration timeout = const Duration(seconds: 2)}) async {
    if (_didRun) return;
    _didRun = true;

    // Optional niceties
    FirebaseAuth.instance.setLanguageCode('en'); // or user locale

    final tasks = <Future>[
      _warmGoogle(),
      _warmApple(),
      _warmPhone(),
    ];

    // Don’t block startup forever—cap total time
    await Future.any([
      Future.wait(tasks).catchError((_) {}),
      Future.delayed(timeout),
    ]);
  }

  static Future<void> _warmGoogle() async {
    try {
      // Prepare client; restore session if present (no dialogs)
      await _gsi.signInSilently(suppressErrors: true);
    } catch (_) {}
  }

  static Future<void> _warmApple() async {
    try {
      _appleAvailable = await SignInWithApple.isAvailable();
    } catch (_) {
      _appleAvailable = false;
    }
  }

  static Future<void> _warmPhone() async {
    // There’s no native “prewarm” call. Keep this lightweight on purpose.
    // If you localize the phone input later, you can prefetch region here.
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}