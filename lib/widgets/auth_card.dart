import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:amalay_user/app/app_routes.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_component_styles.dart';
import 'package:amalay_user/theme/app_layout.dart';
import 'package:amalay_user/theme/app_text_styles.dart';

class AuthCard extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onPhone;
  final VoidCallback onApple;
  final VoidCallback onFacebook;
  final bool fullHeightLayout;

  const AuthCard({
    super.key,
    required this.onGoogle,
    required this.onPhone,
    required this.onApple,
    required this.onFacebook,
    this.fullHeightLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!fullHeightLayout) {
      return const SizedBox.shrink();
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, AppLayout.authHeaderAlignmentY),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.authOuterHorizontalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) => AppComponentStyles
                      .brandTitleGradient
                      .createShader(bounds),
                  child: const Text('Amalay', style: AppTextStyles.authBrand),
                ),
                const SizedBox(height: AppLayout.brandToSubtitleGap),
                const Text(
                  'Find someone who feels like home',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.authSubtitle,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppLayout.authOuterHorizontalPadding,
              AppLayout.authOuterTopPadding,
              AppLayout.authOuterHorizontalPadding,
              bottomInset + AppLayout.authBottomInsetPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppLayout.authMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: AppComponentStyles.authCtaBackdrop,
                    child: const Text(
                      'Continue with',
                      style: AppTextStyles.authPrimaryCta,
                    ),
                  ),
                  const SizedBox(height: AppLayout.ctaToProvidersGap),
                  _iconOnlySignInRow(),
                  const SizedBox(height: AppLayout.providersToLegalGap),
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: AppTextStyles.authLegalBody,
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: _LegalLink(
                            label: 'Terms',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.terms);
                            },
                          ),
                        ),
                        const TextSpan(text: ' • '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: _LegalLink(
                            label: 'Privacy',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.privacy);
                            },
                          ),
                        ),
                        const TextSpan(text: ' • '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: _LegalLink(
                            label: 'Cookies',
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.cookies);
                            },
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconOnlySignInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconCircleButton(
          icon: const Icon(
            Icons.apple,
            color: Colors.white,
            size: AppLayout.appleIconSize,
          ),
          onTap: onApple,
          semantics: 'Continue with Apple',
        ),
        const SizedBox(width: AppLayout.providerGapWide),
        _iconCircleButton(
          icon: _googleMark(),
          onTap: onGoogle,
          semantics: 'Continue with Google',
        ),
        const SizedBox(width: AppLayout.providerGapTight),
        _iconCircleButton(
          icon: const Icon(
            Icons.facebook_rounded,
            color: AppColors.facebookBlue,
            size: AppLayout.facebookIconSize,
          ),
          onTap: onFacebook,
          semantics: 'Continue with Facebook',
        ),
        const SizedBox(width: AppLayout.providerGapTight),
        _iconCircleButton(
          icon: const Icon(
            Icons.phone_outlined,
            color: Colors.white,
            size: AppLayout.phoneIconSize,
          ),
          onTap: onPhone,
          semantics: 'Continue with Phone',
        ),
      ],
    );
  }

  Widget _iconCircleButton({
    required Widget icon,
    required VoidCallback onTap,
    required String semantics,
  }) {
    return _AnimatedAuthIconButton(
      icon: icon,
      onTap: onTap,
      semantics: semantics,
    );
  }

  Widget _googleMark() {
    return ShaderMask(
      shaderCallback: (Rect bounds) =>
          AppComponentStyles.googleMarkGradient.createShader(bounds),
      child: const Text('G', style: AppTextStyles.googleGlyph),
    );
  }
}

class _AnimatedAuthIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String semantics;

  const _AnimatedAuthIconButton({
    required this.icon,
    required this.onTap,
    required this.semantics,
  });

  @override
  State<_AnimatedAuthIconButton> createState() =>
      _AnimatedAuthIconButtonState();
}

class _AnimatedAuthIconButtonState extends State<_AnimatedAuthIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semantics,
      child: AnimatedScale(
        scale: _pressed ? AppLayout.providerPressedScale : 1,
        duration: AppLayout.providerPressDuration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? AppLayout.providerPressedOpacity : 1,
          duration: AppLayout.providerPressDuration,
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: AppComponentStyles.authProviderBorderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppLayout.providerBlur,
                sigmaY: AppLayout.providerBlur,
              ),
              child: SizedBox(
                width: AppLayout.providerSize,
                height: AppLayout.providerSize,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: AppComponentStyles.authProviderDecoration,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.onTap,
                      onHighlightChanged: (value) {
                        if (_pressed == value) return;
                        setState(() => _pressed = value);
                      },
                      splashColor: Colors.white.withValues(alpha: 0.20),
                      highlightColor: Colors.white.withValues(alpha: 0.10),
                      child: Center(child: widget.icon),
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

class _LegalLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LegalLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: AppTextStyles.authLegalLink),
    );
  }
}
