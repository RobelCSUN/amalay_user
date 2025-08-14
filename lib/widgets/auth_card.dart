// lib/screens/home/widgets/auth_card.dart
import 'package:flutter/material.dart';

import 'package:amalay_user/widgets/sign_in/google_sign_in_button.dart';
import 'package:amalay_user/widgets/sign_in/apple_sign_in_button.dart';
import 'package:amalay_user/widgets/sign_in/phone_sign_in_button.dart';

import 'package:amalay_user/widgets/legal/terms_of_service_dialog.dart';
import 'package:amalay_user/widgets/legal/privacy_policy_dialog.dart';
import 'package:amalay_user/widgets/legal/cookies_policy_dialog.dart';

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
        color: Colors.transparent,
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
            isSignUp ? 'Create your account' : 'Amalay',
            style: const TextStyle(
              fontSize: 30,
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

          /// Sign-in buttons in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GoogleSignInFullWidthButton(
                width: 56,
                height: 56,
                onPressed: onGoogle,
              ),
              PhoneSignInFullWidthButton(
                width: 56,
                height: 56,
                onPressed: onPhone,
              ),
              AppleSignInFullWidthButton(
                width: 56,
                height: 56,
                onPressed: onApple,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: const [
              Expanded(child: Divider(color: Colors.black45, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
              Expanded(child: Divider(color: Colors.black45, thickness: 1)),
            ],
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: onToggleCopy,
            child: Text(
              isSignUp
                  ? 'Already have an account? Sign in'
                  : 'Don\'t have an account? Sign up',
              style: const TextStyle(
                fontSize: 15,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text.rich(
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _LegalLink(
                    label: 'Terms of Service',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const TextSpan(text: ' • '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _LegalLink(
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const TextSpan(text: ' • '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _LegalLink(
                    label: 'Cookie Policy',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CookiePolicyScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
