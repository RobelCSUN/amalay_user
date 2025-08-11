import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class GoogleSignInFullWidthButton extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onPressed;

  const GoogleSignInFullWidthButton({
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // keeps rounded corners
        child: SignInButton(
          Buttons.Google,
          text: "Continue with Google", // <-- copy change only
          onPressed: onPressed,
          elevation: 2, // same visual depth as before
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.black26, width: 1),
          ),
        ),
      ),
    );
  }
}