// lib/widgets/sign_in/apple_sign_in_button.dart
import 'package:flutter/material.dart';
import 'package:amalay_user/widgets/sign_in/circular_icon_button.dart';

class AppleSignInFullWidthButton extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onPressed;

  const AppleSignInFullWidthButton({
    super.key,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: CircularIconButton(
          size: height, // circle diameter
          icon: Icons.apple, // Apple logo icon
          tooltip: 'Continue with Apple',
          onPressed: onPressed,
          iconColor: Colors.white,
          backgroundColor: Colors.transparent,
          borderColor: Colors.white.withOpacity(0.5),
          borderWidth: 2,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.08),
        ),
      ),
    );
  }
}
