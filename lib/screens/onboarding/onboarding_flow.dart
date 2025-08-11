import 'package:flutter/material.dart';

class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: you’ll add steps here (age gate, gender, photos, religion, location).
    return Scaffold(
      appBar: AppBar(title: const Text('Finish your profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Welcome! Let’s finish your profile so we can match you properly.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true), // simulate success
              child: const Text('Complete (placeholder)'),
            ),
          ],
        ),
      ),
    );
  }
}