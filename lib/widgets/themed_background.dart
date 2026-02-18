import 'package:flutter/material.dart';

import 'package:amalay_user/theme/app_colors.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;
  final bool useHeroImage;
  final bool isCreateMode;

  const ThemedBackground({
    super.key,
    required this.child,
    this.useHeroImage = false,
    this.isCreateMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final heroAsset = isCreateMode
        ? 'assets/images/habesha_couple_hero.jpg'
        : 'assets/images/habesha_couple_login.jpg';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (useHeroImage)
          Stack(
            fit: StackFit.expand,
            children: [
              // Full-screen fill layer.
              Image.asset(
                heroAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  // Fallback to create mode image if login image is missing.
                  if (!isCreateMode) {
                    return Image.asset(
                      'assets/images/habesha_couple_hero.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                    );
                  }
                  return const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.backgroundGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                },
              ),
              // Proportion-preserving layer that shows more of the original image.
              Image.asset(
                heroAsset,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  if (!isCreateMode) {
                    return Image.asset(
                      'assets/images/habesha_couple_hero.jpg',
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.high,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          )
        else
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.backgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        if (useHeroImage) ...[
          // Top contrast scrim for title readability.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.34, 1.0],
                  colors: [AppColors.heroTopScrim, Color(0x00000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          // Bottom contrast scrim for CTA/buttons/legal readability.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.58, 1.0],
                  colors: [Color(0x00000000), AppColors.heroMidScrim, AppColors.heroBottomScrim],
                ),
              ),
            ),
          ),
        ] else
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.00, 0.62, 1.00],
                  colors: [Color(0x222A1A1A), Color(0x44764639), Color(0x66411F1C)],
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
