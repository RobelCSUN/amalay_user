// lib/widgets/sign_in/phone_sign_in_button.dart
import 'package:flutter/material.dart';

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
    // Match Google/Apple pill look: white card, light shadow, subtle outline.
    final borderRadius = BorderRadius.circular(30);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.white,
        elevation: 2, // subtle depth like Google button
        shadowColor: Colors.black26,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          splashColor: Colors.black12, // gentle feedback
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: Colors.black26, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: const [
                // Fixed 24px icon slot so all three buttons align perfectly.
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: Icon(Icons.phone, size: 20, color: Colors.black54),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Continue with Phone',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(221, 70, 69, 69),
                    fontWeight: FontWeight.w500,
                    height: 1.0, // keeps baseline consistent
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
