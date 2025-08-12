import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignedInCard extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;

  const SignedInCard({super.key, required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final displayName = (user.displayName ?? '').trim();
    final email = (user.email ?? '').trim();
    final hasName = displayName.isNotEmpty;
    final hasEmail = email.isNotEmpty;

    return Container(
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
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.35),
          ),
          const SizedBox(height: 20),

          // Optional avatar if available
          if (user.photoURL != null) ...[
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(user.photoURL!),
            ),
            const SizedBox(height: 12),
          ],

          // Name (if present)
          if (hasName)
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

          // Email (if present)
          if (hasEmail) ...[
            if (hasName) const SizedBox(height: 4),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],

          // If neither name nor email, show a generic label
          if (!hasName && !hasEmail)
            const Text(
              'User',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: 280,
            height: 48,
            child: ElevatedButton(
              onPressed: onSignOut,
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}
