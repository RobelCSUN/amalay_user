import 'package:flutter/material.dart';

class AppColors {
  // App-wide romantic sunset palette.
  static const List<Color> backgroundGradient = [
    Color(0xFF2A1A1A),
    Color(0xFF7B4C3D),
    Color(0xFFD79A72),
  ];

  static const Color accentWarm = Color(0xFFF4D1B4);
  static const Color accentRose = Color(0xFFE7928A);

  static const Color primaryText = Color(0xFFF6F1ED);
  static const Color secondaryText = Color(0xFFE4D6CE);
  static const Color divider = Colors.white54;

  static const Color panelFill = Color(0x52311D19);
  static const Color panelBorder = Color(0x66F4DCCB);
  static const Color panelShadow = Color(0x66000000);

  static const Color buttonFill = Color(0xFFF29A91);
  static const Color buttonText = Color(0xFF2E1B1B);
  static const Color buttonOutline = Color(0x80F8E3D6);

  static const Color authProviderFill = Color(0x4D000000);
  static const Color authProviderBorder = Color(0x73FFFFFF);
  static const Color authProviderHighlight = Color(0x26FFFFFF);
  static const Color authProviderGlow = Color(0x80462A24);
  static const Color legalText = Color(0xEEFFFFFF);

  static const Color facebookBlue = Color(0xFF1877F2);
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEA4335);

  static const Color brandGoldBright = Color(0xFFFFF3E5);
  static const Color brandGoldSoft = Color(0xFFF5D7BA);
  static const Color brandGoldDeep = Color(0xFFD9A47D);
  static const Color directiveCue = Color(0xFFEFD3BF);

  static const Color heroTopScrim = Color(0x5C1A0D0B);
  static const Color heroBottomScrim = Color(0x8A130A09);
  static const Color heroMidScrim = Color(0x3A3B1F1A);

  // In-app (post-auth) surfaces: deep romantic dusk.
  static const List<Color> appBackgroundGradient = [
    Color(0xFF201210),
    Color(0xFF2C1815),
    Color(0xFF3A201B),
  ];
  static const Color surfaceCard = Color(0xFF341E1A);
  static const Color surfaceElevated = Color(0xFF3E2620);
  static const Color surfaceOutline = Color(0x24FFFFFF);

  // Swipe feedback
  static const Color likeGreen = Color(0xFF5DC48A);
  static const Color nopeRed = Color(0xFFE0655C);

  // Premium gold accents
  static const List<Color> premiumGradient = [
    Color(0xFFF6E1B8),
    Color(0xFFE2B978),
    Color(0xFFC98F4E),
  ];

  // Card cover gradients rotated per-profile for visual variety.
  static const List<List<Color>> profileCoverGradients = [
    [Color(0xFF7B4C3D), Color(0xFF3B221D)],
    [Color(0xFF8A5A68), Color(0xFF3A1F2B)],
    [Color(0xFF946A45), Color(0xFF41291A)],
    [Color(0xFF6E4A6B), Color(0xFF2E1D33)],
    [Color(0xFF54697A), Color(0xFF1F2B33)],
  ];
}
