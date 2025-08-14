// lib/widgets/sign_in/google_sign_in_button.dart
import 'package:flutter/material.dart';
import 'package:amalay_user/widgets/sign_in/circular_icon_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      width: width, // can be double.infinity for full-width alignment
      height: height,
      child: Center(
        child: CircularIconButton(
          size: height, // circle diameter = button height
          icon: Icons.g_mobiledata, // replace with a proper "Google G" icon

          tooltip: 'Continue with Google',
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
