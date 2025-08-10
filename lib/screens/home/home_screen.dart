import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Add Apple Sign In support (iOS only)
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// For phone auth (later step)
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      setState(() => user = userCredential.user);
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      setState(() => user = userCredential.user);
    } catch (e) {
      print('Apple Sign-In Error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    setState(() => user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user != null ? 'Welcome' : 'Amalay - Login'),
        actions: user != null
            ? [IconButton(icon: Icon(Icons.logout), onPressed: signOut)]
            : null,
      ),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Logged in as:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    user?.displayName ?? user?.email ?? 'User',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: signOut, child: Text("Sign Out")),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: signInWithGoogle,
                    child: Text("Sign in with Google"),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Add phone auth implementation next
                    },
                    child: Text("Sign in with Phone"),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 250, // match your other buttons
                    child: SignInWithAppleButton(onPressed: signInWithApple),
                  ),
                ],
              ),
      ),
    );
  }
}
