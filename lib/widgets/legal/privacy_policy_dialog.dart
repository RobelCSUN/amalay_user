import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
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

                _H('1) Who We Are'),
                _P(
                  'This Privacy Policy explains how we collect, use, and share information when you use our app and services (“Service”).',
                ),

                _H('2) Information We Collect'),
                _P(
                  '• Account & Profile: name, display name, email/phone, age confirmation, photos, preferences, and any info you provide.\n'
                  '• Usage & Device: app interactions, approximate location (if enabled), device identifiers, crash logs, diagnostics, and settings.\n'
                  '• Communications: messages you send/receive via the Service, support requests, and feedback.\n'
                  '• Cookies/Similar Tech: see Cookie Policy for details.',
                ),

                _H('3) How We Use Information (Lawful Bases under GDPR)'),
                _P(
                  '• Provide the Service (Contract): create/maintain your account; enable matching, messaging, and core features.\n'
                  '• Improve & Personalize (Legitimate Interests/Consent): recommendations, safety features, analytics, and A/B tests.\n'
                  '• Safety & Compliance (Legal Obligation/Legitimate Interests): detect/prevent abuse, enforce Terms, comply with law.\n'
                  '• Marketing (Consent/Legitimate Interests): send updates or offers where permitted; you can opt out.',
                ),

                _H('4) How We Share Information'),
                _P(
                  '• Service Providers: cloud hosting, analytics, customer support, fraud prevention. Bound by contractual safeguards.\n'
                  '• Legal/Protective: to comply with law or protect rights, safety, and security.\n'
                  '• Business Transfers: in a merger, acquisition, or asset sale, your info may transfer, subject to this Policy.\n'
                  '• With Consent: where you ask or clearly consent.',
                ),

                _H('5) International Data Transfers'),
                _P(
                  'Your information may be processed in countries other than your own. Where required, we use appropriate safeguards '
                  '(e.g., Standard Contractual Clauses) to protect your data.',
                ),

                _H('6) Data Retention'),
                _P(
                  'We keep data only as long as necessary for the purposes above, then delete or anonymize it unless we must retain it by law.',
                ),

                _H('7) Your Rights'),
                _P(
                  'EU/UK (GDPR/UK GDPR): access, rectify, erase, restrict, portability, and object to processing (including direct marketing). '
                  'You can also withdraw consent at any time.\n'
                  'California (CCPA/CPRA): right to know, delete, correct, opt-out of “sale”/“sharing” of personal information, and limit use of sensitive information.\n'
                  'Brazil (LGPD): similar rights including access, correction, deletion, and portability.\n'
                  'To exercise rights: privacy@yourapp.example.',
                ),

                _H('8) “Do Not Sell or Share” / Targeted Ads (US States)'),
                _P(
                  'Where legally required, we honor “Do Not Sell or Share My Personal Information” choices and provide mechanisms to opt-out of cross-context behavioral advertising.',
                ),

                _H('9) Children'),
                _P(
                  'The Service is for adults (18+) only. We do not knowingly collect data from minors. If you believe a minor is using the Service, contact us to remove the account.',
                ),

                _H('10) Security'),
                _P(
                  'We use reasonable technical and organizational measures to protect your data. No system is perfectly secure. '
                  'Report concerns to security@yourapp.example.',
                ),

                _H('11) Changes to This Policy'),
                _P(
                  'We may update this Policy. If changes are material, we will provide notice (e.g., in-app). Continued use after changes indicates acceptance.',
                ),

                _H('12) Contact'),
                _P(
                  'Privacy questions/requests: privacy@yourapp.example\n'
                  'If applicable, EU/UK representative and DPO details will be provided upon request.',
                ),
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
