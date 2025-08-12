// lib/screens/auth/phone_auth_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Country {
  final String name;
  final String isoCode; // e.g., "US", "ET"
  final String dialCode; // e.g., "+1", "+251"
  final String flag; // emoji flag

  const Country(this.name, this.isoCode, this.dialCode, this.flag);
}

const List<Country> kCountries = [
  Country('United States', 'US', '+1', '🇺🇸'),
  Country('Canada', 'CA', '+1', '🇨🇦'),
  Country('United Kingdom', 'GB', '+44', '🇬🇧'),
  Country('Ethiopia', 'ET', '+251', '🇪🇹'),
  Country('Eritrea', 'ER', '+291', '🇪🇷'),
  Country('United Arab Emirates', 'AE', '+971', '🇦🇪'),
  Country('Germany', 'DE', '+49', '🇩🇪'),
  Country('France', 'FR', '+33', '🇫🇷'),
  Country('Italy', 'IT', '+39', '🇮🇹'),
  Country('Kenya', 'KE', '+254', '🇰🇪'),
];

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _auth = FirebaseAuth.instance;

  Country? _selectedCountry;
  final _nationalNumberCtrl =
      TextEditingController(); // number WITHOUT country code
  final _codeCtrl = TextEditingController();

  String? _verificationId;
  int? _resendToken;
  bool _sending = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    final ui.Locale sysLocale = ui.PlatformDispatcher.instance.locale;
    final cc = (sysLocale.countryCode ?? '').toUpperCase();
    _selectedCountry = kCountries.firstWhere(
      (c) => c.isoCode == cc,
      orElse: () => kCountries.firstWhere((c) => c.isoCode == 'US'),
    );
    _auth.setLanguageCode('en').catchError((_) {});
  }

  @override
  void dispose() {
    _nationalNumberCtrl.dispose();
    _codeCtrl.dispose();
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
    print(
      '📞 verifyPhoneNumber | phone="$phoneE164" | resendToken=$_resendToken',
    );

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneE164,
        forceResendingToken: isResend ? _resendToken : null,
        verificationCompleted: (PhoneAuthCredential cred) async {
          print('✅ verificationCompleted (auto)');
          try {
            final res = await _auth.signInWithCredential(cred);
            print('✅ auto sign-in success: uid=${res.user?.uid}');
            if (mounted) Navigator.pop(context, true);
          } catch (e) {
            print('❌ auto sign-in error: $e');
            _snack('Auto sign-in failed');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ verificationFailed: code=${e.code} message=${e.message}');
          _snack(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          print(
            '📨 codeSent: verificationId=$verificationId, resendToken=$resendToken',
          );
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _codeSent = true;
          });
          _snack('Code sent. Check your SMS.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ timeout: verificationId=$verificationId');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      print('✅ verifyPhoneNumber call returned');
    } catch (e) {
      print('🔥 verifyPhoneNumber threw: $e');
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
    print('🔐 verifying code: $_verificationId : $code');

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      final result = await _auth.signInWithCredential(cred);
      print('✅ manual sign-in success: uid=${result.user?.uid}');
      if (mounted) Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      print(
        '❌ signInWithCredential error: code=${e.code} message=${e.message}',
      );
      _snack(e.message ?? 'Invalid code');
    } catch (e) {
      print('🔥 signInWithCredential unknown error: $e');
      _snack('Could not verify the code');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifying = _codeSent;

    return Scaffold(
      appBar: AppBar(
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
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!verifying) ...[
                    // Country dropdown (full width)
                    DropdownButtonFormField<Country>(
                      value: _selectedCountry,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Country'),
                      items: kCountries.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            '${c.flag} ${c.name} (${c.dialCode})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (c) => setState(() => _selectedCountry = c),
                    ),
                    const SizedBox(height: 12),

                    // National number field (full width) with dial code prefix
                    TextField(
                      controller: _nationalNumberCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Number',
                        hintText: _selectedCountry?.isoCode == 'US'
                            ? '5551234567'
                            : '912345678',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
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

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _sending ? null : () => _sendCode(),
                        child: const Text('Send Code'),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'SMS code'),
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
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
