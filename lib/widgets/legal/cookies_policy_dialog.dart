import 'package:flutter/material.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cookie Policy')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: DefaultTextStyle(
            style: theme.textTheme.bodyMedium!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _H('Last Updated'),
                _P('September 2025'),

                _H('1) What Are Cookies?'),
                _P(
                  'Cookies are small files stored on your device to help apps remember settings and understand how the app is used. '
                  'We also use similar technologies like device identifiers and local storage.',
                ),

                _H('2) How We Use Cookies'),
                _P(
                  '• Essential: required to run the app and keep you signed in.\n'
                  '• Preferences: remember your choices and settings.\n'
                  '• Analytics: understand usage and improve performance.\n'
                  '• Marketing/Personalization (where permitted): show relevant content.',
                ),

                _H('3) Managing Cookies & Tracking'),
                _P(
                  'You can control cookies and similar technologies through device settings, in-app settings (if available), and platform privacy controls. '
                  'Blocking certain categories may impact features.',
                ),

                _H('4) “Do Not Sell/Share” & Targeted Ads'),
                _P(
                  'In regions with such laws, we provide controls to opt-out of the “sale” or “sharing” of personal information and opt-out of cross-context behavioral advertising.',
                ),

                _H('5) Changes'),
                _P(
                  'We may update this Cookie Policy. Continued use after changes means you accept the updated policy.',
                ),

                _H('6) Contact'),
                _P('Questions: privacy@yourapp.example'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 6),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _P extends StatelessWidget {
  final String text;
  const _P(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text));
}
