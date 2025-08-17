// lib/screens/auth/phone_auth_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Theme + data
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/data/countries_area_code.dart';
import 'package:amalay_user/theme/app_text_styles.dart';

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
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Phone Sign-In',
            style: AppTextStyles.heroTitle.copyWith(fontSize: 20),
          ),
          actions: [
            if (_codeSent)
              TextButton(
                onPressed: _sending ? null : () => _sendCode(isResend: true),
                child: Text(
                  'Resend',
                  style: AppTextStyles.link.copyWith(fontSize: 14),
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
                      Text(
                        'Verify your phone',
                        style: AppTextStyles.heroTitle.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We need to confirm you’re a real person with a real phone number. '
                        'We’ll send a one-time code by SMS.',
                        style: AppTextStyles.heroBody.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 20),

                      if (!verifying) ...[
                        DropdownButtonFormField<Country>(
                          value: _selectedCountry,
                          isExpanded: true,
                          style: AppTextStyles.heroBody,
                          decoration: InputDecoration(
                            labelText: 'Country',
                            labelStyle: AppTextStyles.heroBody,
                          ),
                          dropdownColor: AppColors.backgroundGradient.first
                              .withOpacity(0.95),
                          items: kCountries.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                '${c.flag} ${c.name} (${c.dialCode})',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heroBody,
                              ),
                            );
                          }).toList(),
                          onChanged: (c) =>
                              setState(() => _selectedCountry = c),
                          iconEnabledColor: AppTextStyles.heroBody.color
                              ?.withOpacity(0.85),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          focusNode: _numberFocus,
                          controller: _nationalNumberCtrl,
                          style: AppTextStyles.heroBody,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Number',
                            labelStyle: AppTextStyles.heroBody,
                            hintStyle: AppTextStyles.heroBody.copyWith(
                              color: AppTextStyles.heroBody.color?.withOpacity(
                                0.7,
                              ),
                            ),
                            hintText: _selectedCountry?.isoCode == 'US'
                                ? '5551234567'
                                : '912345678',
                            prefix: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                _selectedCountry?.dialCode ?? '',
                                style: AppTextStyles.heroBody.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              size: 18,
                              color: AppTextStyles.heroBody.color?.withOpacity(
                                0.9,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Your phone number will not be shown on your profile.',
                                style: AppTextStyles.legal.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // solid white pill
                              foregroundColor:
                                  Colors.black87, // icon/text color
                              elevation: 1,
                              shape: const StadiumBorder(),
                              textStyle: AppTextStyles.button.copyWith(
                                color: Colors.black87,
                                // Remove any text shadows so it stays crisp on light pill
                                shadows: const [],
                              ),
                            ),
                            onPressed: _sending ? null : () => _sendCode(),
                            child: const Text('Get Verification Code'),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _codeCtrl,
                          style: AppTextStyles.heroBody,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'SMS code',
                            labelStyle: AppTextStyles.heroBody,
                            hintStyle: AppTextStyles.heroBody.copyWith(
                              color: AppTextStyles.heroBody.color?.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 1,
                              shape: const StadiumBorder(),
                              textStyle: AppTextStyles.button.copyWith(
                                color: Colors.black87,
                                shadows: const [],
                              ),
                            ),
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
