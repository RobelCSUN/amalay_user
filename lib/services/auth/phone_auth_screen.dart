import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:amalay_user/data/countries_area_code.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_text_styles.dart';
import 'package:amalay_user/widgets/themed_background.dart';
import 'package:amalay_user/widgets/themed_panel.dart';

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
  final _numberFocus = FocusNode();
  final GlobalKey _countryFieldKey = GlobalKey();

  String? _verificationId;
  int? _resendToken;
  bool _sending = false;
  bool _codeSent = false;
  bool _countryMenuOpen = false;

  @override
  void initState() {
    super.initState();

    final sysLocale = ui.PlatformDispatcher.instance.locale;
    final cc = (sysLocale.countryCode ?? '').toUpperCase();
    _selectedCountry = kCountries.firstWhere(
      (c) => c.isoCode == cc,
      orElse: () => kCountries.firstWhere((c) => c.isoCode == 'US'),
    );

    _auth.setLanguageCode('en').catchError((_) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _numberFocus.requestFocus();
    });

    _nationalNumberCtrl.addListener(() {
      if (mounted) setState(() {});
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

  Future<void> _openCountryMenu() async {
    setState(() => _countryMenuOpen = true);

    final box = _countryFieldKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final fieldTopLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
    final fieldBottomRight = box.localToGlobal(
      box.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        Offset(fieldTopLeft.dx, fieldBottomRight.dy + 6),
        Offset(fieldBottomRight.dx, fieldBottomRight.dy + 6),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<Country>(
      context: context,
      position: position,
      color: AppColors.backgroundGradient.first.withValues(alpha: 0.96),
      elevation: 8,
      constraints: BoxConstraints(
        minWidth: box.size.width,
        maxWidth: box.size.width,
        maxHeight: 320,
      ),
      items: kCountries.map((c) {
        return PopupMenuItem<Country>(
          value: c,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  '${c.flag} ${c.name} (${c.dialCode})',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heroBody,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (!mounted) return;
    setState(() => _countryMenuOpen = false);

    if (selected != null) {
      setState(() => _selectedCountry = selected);
      _numberFocus.requestFocus();
      _nationalNumberCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _nationalNumberCtrl.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifying = _codeSent;

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
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
                  child: ThemedPanel(
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
                          Text(
                            _countryMenuOpen
                                ? 'Scroll to select country'
                                : 'Country',
                            style: AppTextStyles.heroBody,
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            key: _countryFieldKey,
                            borderRadius: BorderRadius.circular(8),
                            onTap: _openCountryMenu,
                            child: InputDecorator(
                              decoration: const InputDecoration(isDense: true),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${_selectedCountry?.flag ?? ''} ${_selectedCountry?.name ?? ''} (${_selectedCountry?.dialCode ?? ''})',
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.heroBody,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.expand_more,
                                    size: 24,
                                    color: AppTextStyles.heroBody.color
                                            ?.withValues(alpha: 0.9) ??
                                        Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            focusNode: _numberFocus,
                            controller: _nationalNumberCtrl,
                            style: AppTextStyles.heroBody,
                            keyboardType: TextInputType.phone,
                            cursorColor: Colors.white,
                            cursorWidth: 1.5,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Number',
                              labelStyle: AppTextStyles.heroBody,
                              prefix: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  _selectedCountry?.dialCode ?? '',
                                  style: AppTextStyles.heroBody.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
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
                                color: AppTextStyles.heroBody.color
                                    ?.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Your phone number will not be shown on your profile.',
                                  style:
                                      AppTextStyles.legal.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: (_sending ||
                                      _digitsOnly(_nationalNumberCtrl.text)
                                              .length <
                                          3)
                                  ? null
                                  : () => _sendCode(),
                              child: const Text('Get Verification Code'),
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: _codeCtrl,
                            style: AppTextStyles.heroBody,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.white,
                            cursorWidth: 1.5,
                            decoration: InputDecoration(
                              labelText: 'SMS code',
                              labelStyle: AppTextStyles.heroBody,
                              hintStyle: AppTextStyles.heroBody.copyWith(
                                color: AppTextStyles.heroBody.color
                                    ?.withValues(alpha: 0.7),
                              ),
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
      ),
    );
  }
}
