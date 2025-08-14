import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
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

                _H('1) Acceptance of Terms'),
                _P(
                  'By creating an account, accessing, or using the app (the “Service”), you agree to these Terms of Service (“Terms”) and our Privacy & Cookie Policies. '
                  'If you do not agree, do not use the Service.',
                ),

                _H('2) Eligibility'),
                _P(
                  'You must be at least 18 years old or the age of majority in your jurisdiction. By using the Service you represent and warrant that you meet this requirement.',
                ),

                _H('3) Account & Security'),
                _P(
                  'You are responsible for your account credentials and for all activity under your account. Keep your login secure and notify us immediately of any unauthorized use.',
                ),

                _H('4) Acceptable Use'),
                _P(
                  'You agree not to use the Service for illegal or harmful purposes, including harassment, hate speech, threats, impersonation, spamming, scraping, reverse engineering, '
                  'or interfering with the Service.',
                ),

                _H('5) User Content'),
                _P(
                  'You retain ownership of content you post. You grant us a non-exclusive, worldwide, royalty-free license to host, store, reproduce, and display your content only as '
                  'needed to operate and improve the Service. You are solely responsible for your content and interactions.',
                ),

                _H('6) No Background Checks; Safety Notice'),
                _P(
                  'We do not routinely verify users’ identities or conduct criminal background checks. Exercise caution when meeting others. We are not responsible for user conduct.',
                ),

                _H('7) Subscriptions, Billing & Refunds (if applicable)'),
                _P(
                  'If you purchase paid features, you authorize us (and/or the app store) to charge applicable fees and taxes. Subscriptions auto-renew until you cancel at least 24 hours '
                  'before the renewal period through your app store settings. Refunds, if any, are handled per app store policy.',
                ),

                _H('8) Intellectual Property'),
                _P(
                  'The Service, including software, trademarks, logos, and content (excluding user content), is our property or that of our licensors and is protected by law. '
                  'Do not copy, modify, or distribute without permission.',
                ),

                _H('9) Third-Party Services'),
                _P(
                  'The Service may contain links to third-party sites or services. We are not responsible for their content or practices.',
                ),

                _H('10) Disclaimers'),
                _P(
                  'THE SERVICE IS PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, '
                  'NON-INFRINGEMENT, AND AVAILABILITY. WE DO NOT GUARANTEE MATCHES, COMPATIBILITY, OR PARTICULAR OUTCOMES.',
                ),

                _H('11) Limitation of Liability'),
                _P(
                  'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, EXEMPLARY, OR PUNITIVE DAMAGES; '
                  'OR ANY LOSS OF PROFITS, DATA, REPUTATION, OR OTHER INTANGIBLE LOSSES, ARISING FROM OR RELATED TO YOUR USE OF THE SERVICE.',
                ),

                _H('12) Indemnity'),
                _P(
                  'You agree to defend, indemnify, and hold us harmless from claims, liabilities, damages, losses, and expenses, including reasonable legal fees, arising from '
                  'your use of the Service or violation of these Terms.',
                ),

                _H('13) Termination'),
                _P(
                  'We may suspend or terminate your account or access at any time for any reason, including violations of these Terms or to protect users or the Service.',
                ),

                _H('14) Changes to the Terms'),
                _P(
                  'We may update these Terms. If changes are material, we will provide reasonable notice (e.g., in-app notice). Continued use after changes become effective '
                  'constitutes acceptance.',
                ),

                _H('15) Governing Law & Dispute Resolution'),
                _P(
                  'Except where prohibited by law, these Terms are governed by the laws of your primary operating entity’s jurisdiction (to be specified in your company details). '
                  'Disputes will be resolved in that venue. Consumers may have non-waivable rights under local law.',
                ),

                _H('16) Contact'),
                _P('Questions about these Terms: support@yourapp.example'),
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _P extends StatelessWidget {
  final String text;
  const _P(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text));
}
