import 'package:flutter/material.dart';
import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_component_styles.dart';

class AppTextStyles {
  // Crisp & vibrant universal style base
  static const TextStyle _crispBase = TextStyle(
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.3,
    letterSpacing: 0.4, // subtle spacing makes text look sharper
    shadows: [
      Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  // Hero Title (large, bold, modern)
  static final TextStyle heroTitle = _crispBase.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.6,
  );

  // Hero Body (slightly larger, cleaner readability)
  static final TextStyle heroBody = _crispBase.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.85),
  );

  // Separator (like the 'or' text, brighter for contrast)
  static final TextStyle separator = _crispBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.9),
  );

  // Link (high-contrast underlined)
  static final TextStyle link = _crispBase.copyWith(
    fontSize: 12,
    decoration: TextDecoration.underline,
    decorationThickness: 1.5,
    decorationColor: Colors.white,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  // Legal (smaller, but keep it crisp and visible)
  static final TextStyle legal = _crispBase.copyWith(
    fontSize: 12,
    color: Colors.white70,
    fontWeight: FontWeight.w400,
  );

  // Buttons (slightly bolder for modern UI feel)
  static final TextStyle button = _crispBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Crisp Title (for dialogs like Verify Phone)
  static final TextStyle crispTitle = _crispBase.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle authBrand = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.6,
    fontFamily: 'Georgia',
    shadows: AppComponentStyles.heroTextShadows,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 21,
    color: Color(0xF2FFFFFF),
    height: 1.25,
    shadows: AppComponentStyles.subtitleTextShadows,
  );

  static const TextStyle authPrimaryCta = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.directiveCue,
    letterSpacing: 0.7,
    shadows: AppComponentStyles.legalTextShadows,
  );

  static const TextStyle authLegalBody = TextStyle(
    color: AppColors.legalText,
    fontSize: 15,
    shadows: AppComponentStyles.legalTextShadows,
  );

  static const TextStyle authLegalLink = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationColor: Colors.white,
  );

  static const TextStyle googleGlyph = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
