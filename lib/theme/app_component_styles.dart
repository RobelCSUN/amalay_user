import 'package:flutter/material.dart';

import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_layout.dart';

class AppComponentStyles {
  static const List<Shadow> heroTextShadows = [
    Shadow(
      color: Color.fromARGB(90, 0, 0, 0),
      blurRadius: 1,
      offset: Offset(0, 2),
    ),
  ];

  static const List<Shadow> subtitleTextShadows = [
    Shadow(
      color: Color.fromARGB(75, 0, 0, 0),
      blurRadius: 0.8,
      offset: Offset(0, 1),
    ),
  ];

  static const List<Shadow> legalTextShadows = [
    Shadow(
      color: Color.fromARGB(65, 0, 0, 0),
      blurRadius: 0.8,
      offset: Offset(0, 1),
    ),
  ];

  /// Warm glass circle tuned to sit over the sunset hero photo: a soft
  /// top-light, a gold-tinted rim, and a warm ambient glow.
  static BoxDecoration authProviderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x33FFF3E5),
        AppColors.authProviderFill,
        Color(0x59000000),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
    border: Border.all(color: const Color(0x80F4DCCB), width: 1.2),
    boxShadow: const [
      BoxShadow(
        color: AppColors.authProviderGlow,
        blurRadius: 18,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
      // Faint gold halo so the circles feel lit by the sunset.
      BoxShadow(
        color: Color(0x26D9A47D),
        blurRadius: 24,
        spreadRadius: 1,
        offset: Offset(0, 0),
      ),
    ],
  );

  static const BoxDecoration authTopTextBackdrop = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x5C000000), Color(0x12000000)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(18)),
  );

  static const BoxDecoration authCtaBackdrop = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x4D000000), Color(0x14000000)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static const SweepGradient googleMarkGradient = SweepGradient(
    center: Alignment.center,
    startAngle: 0.0,
    endAngle: 6.28318530718,
    colors: [
      AppColors.googleBlue,
      AppColors.googleGreen,
      AppColors.googleYellow,
      AppColors.googleRed,
      AppColors.googleBlue,
    ],
  );

  static const LinearGradient brandTitleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.brandGoldBright,
      AppColors.brandGoldSoft,
      AppColors.brandGoldDeep,
    ],
  );

  static BorderRadius authProviderBorderRadius = BorderRadius.circular(
    AppLayout.providerRadius,
  );
}
