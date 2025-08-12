// lib/screens/home/widgets/auth_card.dart
import 'package:flutter/material.dart';
import 'package:amalay_user/widgets/sign_in/google_sign_in_button.dart';
import 'package:amalay_user/widgets/sign_in/phone_sign_in_button.dart';
import 'package:amalay_user/widgets/sign_in/apple_sign_in_button.dart';

class AuthCard extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback onToggleCopy;
  final VoidCallback onGoogle;
  final VoidCallback onPhone;
  final VoidCallback onApple;

  const AuthCard({
    super.key,
    required this.isSignUp,
    required this.onToggleCopy,
    required this.onGoogle,
    required this.onPhone,
    required this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            isSignUp ? 'Create your Amalay account' : 'Amalay',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSignUp
                ? 'Sign up to start turning quiet weekends into unforgettable moments.'
                : 'Just a swipe away from turning quiet weekends into unforgettable moments together.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),

          // Buttons (visual + behavior unchanged)
          GoogleSignInFullWidthButton(
            width: double.infinity,
            height: 48,
            onPressed: onGoogle,
          ),
          const SizedBox(height: 12),
          PhoneSignInFullWidthButton(
            width: double.infinity,
            height: 48,
            onPressed: onPhone,
          ),
          const SizedBox(height: 12),
          AppleSignInFullWidthButton(
            width: double.infinity,
            height: 48,
            onPressed: onApple,
          ),

          const SizedBox(height: 20),
          GestureDetector(
            onTap: onToggleCopy,
            child: Text(
              isSignUp
                  ? 'Already have an account? Sign in'
                  : 'Don\'t have an account? Sign up',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
