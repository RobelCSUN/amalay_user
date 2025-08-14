// lib/screens/auth/phone_auth_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Theme + data
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/data/countries_area_code.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _auth = FirebaseAuth.instance;

  Country? _selectedCountry;
  final _nationalNumberCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  // Focus the number field on load
  final _numberFocus = FocusNode();

  String? _verificationId;
  int? _resendToken;
  bool _sending = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();

    // Pick default country from device locale (fallback to US)
    final ui.Locale sysLocale = ui.PlatformDispatcher.instance.locale;
    final cc = (sysLocale.countryCode ?? '').toUpperCase();
    _selectedCountry = kCountries.firstWhere(
      (c) => c.isoCode == cc,
      orElse: () => kCountries.firstWhere((c) => c.isoCode == 'US'),
    );

    _auth.setLanguageCode('en').catchError((_) {});

    // Focus the number field after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _numberFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nationalNumberCtrl.dispose();
    _codeCtrl.dispose();
    _numberFocus.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D+'), '');

  String? _buildE164() {
    final c = _selectedCountry;
    if (c == null) return null;
    final national = _digitsOnly(_nationalNumberCtrl.text);
    if (national.isEmpty) return null;
    return '${c.dialCode}$national';
  }

  Future<void> _sendCode({bool isResend = false}) async {
    final phoneE164 = _buildE164();
    if (phoneE164 == null) {
      _snack('Enter your number (e.g. 5551234567)');
      return;
    }

    setState(() => _sending = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneE164,
        forceResendingToken: isResend ? _resendToken : null,
        verificationCompleted: (PhoneAuthCredential cred) async {
          try {
            await _auth.signInWithCredential(cred);
            if (mounted) Navigator.pop(context, true);
          } catch (_) {
            _snack('Auto sign-in failed');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _snack(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _codeSent = true;
          });
          _snack('Code sent. Check your SMS.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (_) {
      _snack('Could not start verification. Check network or settings.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (_verificationId == null || code.isEmpty) {
      _snack('Enter the SMS code you received');
      return;
    }

    setState(() => _sending = true);

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _auth.signInWithCredential(cred);
      if (mounted) Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      _snack(e.message ?? 'Invalid code');
    } catch (_) {
      _snack('Could not verify the code');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifying = _codeSent;

    // ⬇️ Put the gradient OUTSIDE the Scaffold and make Scaffold transparent
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Phone Sign-In'),
          actions: [
            if (_codeSent)
              TextButton(
                onPressed: _sending ? null : () => _sendCode(isResend: true),
                child: const Text(
                  'Resend',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading + helper text
                      const Text(
                        'Verify your phone',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We need to confirm you’re a real person with a real phone number. '
                        'We’ll send a one-time code by SMS.',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      if (!verifying) ...[
                        // Country dropdown
                        DropdownButtonFormField<Country>(
                          value: _selectedCountry,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                          ),
                          dropdownColor: Colors.white,
                          items: kCountries.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                '${c.flag} ${c.name} (${c.dialCode})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (c) =>
                              setState(() => _selectedCountry = c),
                        ),
                        const SizedBox(height: 12),

                        // National number field
                        TextField(
                          focusNode: _numberFocus,
                          controller: _nationalNumberCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Number',
                            hintText: _selectedCountry?.isoCode == 'US'
                                ? '5551234567'
                                : '912345678',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 8,
                              ),
                              child: Text(
                                _selectedCountry?.dialCode ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Privacy note above button
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.privacy_tip,
                              size: 18,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Your phone number will not be shown on your profile.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Get Verification Code button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _sending ? null : () => _sendCode(),
                            child: const Text('Get Verification Code'),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _codeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'SMS code',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _sending ? null : _verifyCode,
                            child: const Text('Verify Code'),
                          ),
                        ),
                      ],

                      if (_sending)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
