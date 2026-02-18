import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:amalay_user/app/app_routes.dart';

class AuthCard extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback onToggleCopy;
  final VoidCallback onGoogle;
  final VoidCallback onPhone;
  final VoidCallback onApple;
  final bool fullHeightLayout;

  const AuthCard({
    super.key,
    required this.isSignUp,
    required this.onToggleCopy,
    required this.onGoogle,
    required this.onPhone,
    required this.onApple,
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
          alignment: const Alignment(0, -0.76),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Amalay',
                  style: TextStyle(
                    fontSize: 66,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(90, 0, 0, 0),
                        blurRadius: 1,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSignUp
                      ? 'Find someone who feels like home.'
                      : 'Welcome back. Let\'s continue your story.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white.withValues(alpha: 0.96),
                    shadows: const [
                      Shadow(
                        color: Color.fromARGB(75, 0, 0, 0),
                        blurRadius: 0.8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _modeToggleOrb(),
                  const SizedBox(height: 12),
                  _iconOnlySignInRow(),
                  const SizedBox(height: 18),
                  Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.93),
                        fontSize: 15,
                        shadows: const [
                          Shadow(
                            color: Color.fromARGB(65, 0, 0, 0),
                            blurRadius: 0.8,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
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
                            label: 'Cookie',
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

  Widget _modeToggleOrb() {
    final label = isSignUp ? 'Sign in' : 'Create';
    final icon = isSignUp
        ? Icons.login_rounded
        : Icons.person_add_alt_1_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.52),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(60, 0, 0, 0),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggleCopy,
                  child: Icon(icon, size: 22, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: const [
              Shadow(
                color: Color.fromARGB(70, 0, 0, 0),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
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
          icon: const Icon(Icons.apple, color: Colors.white, size: 34),
          onTap: onApple,
          semantics: 'Continue with Apple',
        ),
        const SizedBox(width: 14),
        _iconCircleButton(
          icon: _googleMark(),
          onTap: onGoogle,
          semantics: 'Continue with Google',
        ),
        const SizedBox(width: 14),
        _iconCircleButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.white, size: 32),
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
    return Semantics(
      button: true,
      label: semantics,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SizedBox(
            width: 84,
            height: 84,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: Center(child: icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMark() {
    return ShaderMask(
      shaderCallback: (Rect bounds) => const SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 6.28318530718,
        colors: [
          Color(0xFF4285F4), // blue
          Color(0xFF34A853), // green
          Color(0xFFFBBC05), // yellow
          Color(0xFFEA4335), // red
          Color(0xFF4285F4), // blue
        ],
      ).createShader(bounds),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          color: Colors.white,
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
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
        ),
      ),
    );
  }
}
