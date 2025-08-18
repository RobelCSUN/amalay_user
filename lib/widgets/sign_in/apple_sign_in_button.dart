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
          onPressed: onPressed,
          iconColor: Colors.white,
          backgroundColor: Colors.transparent,
          borderColor: Colors.white.withValues(alpha: 0.5),
          borderWidth: 2,
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}
