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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Colors.black12, // ripple effect
          highlightColor: Colors.black12.withOpacity(0.05), // subtle press feedback
          onTap: onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30), // Match Apple & Phone
            child: SignInButton(
              Buttons.Google,
              text: "Sign in with Google",
              onPressed: onPressed,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.black26, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}