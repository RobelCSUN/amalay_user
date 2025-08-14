// lib/widgets/sign_in/phone_sign_in_button.dart
import 'package:flutter/material.dart';
import 'package:amalay_user/widgets/sign_in/circular_icon_button.dart';

class PhoneSignInFullWidthButton extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onPressed;

  const PhoneSignInFullWidthButton({
    super.key,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // can be double.infinity for full-width alignment
      height: height,
      child: Center(
        child: CircularIconButton(
          size: height, // circle diameter = height
          icon: Icons.phone,
          tooltip: 'Continue with Phone',
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
