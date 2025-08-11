import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      child: SignInWithAppleButton(
        onPressed: onPressed,
        style: SignInWithAppleButtonStyle.black, // Can also be white or whiteOutline
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        text: 'Continue with Apple', // ✅ Official allowed text option
      ),
    );
  }
}