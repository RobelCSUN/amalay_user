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
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary.withOpacity(.08),
          foregroundColor: primary,
          shape: const StadiumBorder(),
          side: const BorderSide(color: Colors.black12, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone, size: 18),
            SizedBox(width: 10),
            Text('Continue with Phone'), // <-- label change only
          ],
        ),
      ),
    );
  }
}