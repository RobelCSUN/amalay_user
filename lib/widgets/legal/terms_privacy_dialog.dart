// lib/widgets/legal/terms_privacy_dialog.dart
import 'package:flutter/material.dart';

/// Call this to open the Terms & Privacy dialog:
///   showTermsPrivacyDialog(context);
Future<void> showTermsPrivacyDialog(BuildContext context) async {
  final theme = Theme.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // allow tap outside to close
    builder: (ctx) {
      final media = MediaQuery.of(ctx).size;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: media.height * 0.75, // scrollable area height
          ),
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Terms & Privacy Policy',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 16),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: const _LegalContent(),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _LegalContent extends StatelessWidget {
  const _LegalContent();

  @override
  Widget build(BuildContext context) {
    final sectionTitle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final body = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. Acceptance of Terms', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'By creating an account, accessing, or using this app, you agree to be bound by these Terms of Use and our Privacy Policy. '
          'If you do not agree, please do not use the app.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('2. Eligibility', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'You must be at least 18 years old (or the age of majority in your jurisdiction) to use this app. By using the app, '
          'you represent and warrant that you meet this requirement.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('3. Account Registration & Security', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'You are responsible for the accuracy of the information you provide and for maintaining the confidentiality of your account credentials. '
          'You agree to notify us immediately of any unauthorized use of your account.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('4. Acceptable Use', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'You agree not to use the app for any unlawful, harmful, or abusive purpose. This includes, but is not limited to, '
          'harassment, hate speech, impersonation, distributing spam, data scraping, or attempting to interfere with the app’s operation.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('5. User Content & Conduct', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'You retain ownership of content you submit, but grant us a non-exclusive, worldwide, royalty-free license to host and display it to operate the service. '
          'You are solely responsible for your content and communications with others. We may remove content that violates these terms.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('6. Privacy Policy', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'We collect and process personal information as described in this Privacy Policy. This may include your name, contact information, '
          'profile details, usage data, and device information. We use this data to provide and improve our services, ensure safety, and comply with legal obligations. '
          'We do not sell your personal data. We may share information with service providers who support our operations, subject to appropriate safeguards.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('7. Data Security', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'We implement reasonable and appropriate safeguards to protect your information. However, no method of transmission or storage is completely secure, '
          'and we cannot guarantee absolute security.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('8. Location & Permissions', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'Some features may require access to device permissions (e.g., location, camera, photos). You can control permissions in your device settings. '
          'Disabling permissions may limit certain app functionality.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('9. Safety & Interactions with Others', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'Please exercise caution and good judgment when interacting with other users. We do not conduct criminal background checks and do not guarantee the identity '
          'or intentions of any user. You are solely responsible for your interactions and any consequences that arise.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('10. Disclaimers', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'THE APP IS PROVIDED “AS IS” AND “AS AVAILABLE” WITHOUT WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED. '
          'WE DISCLAIM ALL WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. '
          'WE DO NOT WARRANT THAT THE APP WILL BE UNINTERRUPTED, ERROR-FREE, OR SECURE.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('11. Limitation of Liability', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, '
          'OR ANY LOSS OF PROFITS OR REVENUES, WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, '
          'RESULTING FROM YOUR USE OF OR INABILITY TO USE THE APP.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('12. Termination', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'We may suspend or terminate your access to the app for any violation of these terms, unlawful behavior, or to protect other users or our service.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('13. Changes to These Terms', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          'We may update these Terms & Privacy Policy from time to time. We will post the updated version in the app and update the “Last Updated” date below. '
          'Your continued use of the app after changes become effective constitutes acceptance of the revised terms.',
          style: body,
        ),

        const SizedBox(height: 16),
        Text('14. Contact Us', style: sectionTitle),
        const SizedBox(height: 8),
        Text(
          // Email needs to be added
          'If you have questions about these Terms or our Privacy Policy, please contact us at: support@yourapp.example.',
          style: body,
        ),

        const SizedBox(height: 20),
        Text(
          'Last Updated: August 2025',
          style: body?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}


//https://www.irs.gov/businesses/small-businesses-self-employed/if-you-no-longer-need-your-ein