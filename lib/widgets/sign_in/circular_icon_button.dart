// lib/widgets/sign_in/circular_icon_button.dart
import 'package:flutter/material.dart';

/// A global, reusable circular icon button with proper ripple (Ink) effects.
/// Use it for Google/Apple/Facebook or *any* circular icon action in the app.
///
/// Example:
/// CircularIconButton(
///   size: 48,
///   icon: Icons.g_mobiledata, // or a custom IconData
///   onPressed: _handleGoogle,
/// )
class CircularIconButton extends StatelessWidget {
  /// Visual size of the button (width = height = size).
  final double size;

  /// Called when tapped.
  final VoidCallback? onPressed;

  /// The icon to render centered inside the circle.
  final IconData icon;

  /// Optional label for accessibility/semantics and Tooltip.
  final String? tooltip;

  /// Icon color (default white).
  final Color iconColor;

  /// Circle fill color (default transparent).
  final Color backgroundColor;

  /// Border color around the circle (default semi-transparent white).
  final Color borderColor;

  /// Border width (default 2).
  final double borderWidth;

  /// Optional custom splash color (ripple). If null, derived from [iconColor].
  final Color? splashColor;

  /// Optional custom highlight color. If null, derived from [iconColor].
  final Color? highlightColor;

  const CircularIconButton({
    super.key,
    required this.size,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.borderColor = const Color.fromARGB(127, 255, 255, 255), // white54
    this.borderWidth = 2.0,
    this.splashColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedSplash = splashColor ?? iconColor.withOpacity(0.20);
    final resolvedHighlight = highlightColor ?? iconColor.withOpacity(0.08);

    Widget button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias, // ensures ripple stays inside circle
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: resolvedSplash,
          highlightColor: resolvedHighlight,
          child: Center(
            child: Icon(
              icon,
              size: size * 0.6, // good visual balance
              color: iconColor,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Semantics(
      // Helps screen readers; if tooltip not given, fall back to icon's name-ish
      button: true,
      label: tooltip,
      child: button,
    );
  }
}
