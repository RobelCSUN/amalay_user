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

  static BoxDecoration authProviderDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.authProviderHighlight, AppColors.authProviderFill],
    ),
    border: Border.all(color: AppColors.authProviderBorder),
    boxShadow: const [
      BoxShadow(
        color: AppColors.authProviderGlow,
        blurRadius: 16,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 6,
        offset: Offset(0, 2),
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
