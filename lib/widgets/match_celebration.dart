// lib/widgets/match_celebration.dart
import 'package:flutter/material.dart';

import 'package:amalay_user/theme/app_colors.dart';
import 'package:amalay_user/theme/app_component_styles.dart';

/// Full-screen "It's a Match!" moment with scale-in avatars.
Future<void> showMatchCelebration(
  BuildContext context, {
  required String myName,
  required String matchName,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'match',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 380),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: curved, child: child),
      );
    },
    pageBuilder: (context, _, __) =>
        _MatchCelebration(myName: myName, matchName: matchName),
  );
}

class _MatchCelebration extends StatelessWidget {
  final String myName;
  final String matchName;

  const _MatchCelebration({required this.myName, required this.matchName});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppComponentStyles
                      .brandTitleGradient
                      .createShader(bounds),
                  child: const Text(
                    "It's a Match!",
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You and $matchName like each other.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _avatar(myName, AppColors.accentRose),
                    Transform.translate(
                      offset: const Offset(0, 26),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.accentRose,
                          size: 36,
                        ),
                      ),
                    ),
                    _avatar(matchName, AppColors.brandGoldDeep),
                  ],
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chat is coming in the next milestone.',
                          ),
                        ),
                      );
                    },
                    child: Text('Say hello to $matchName'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Keep discovering',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: AppColors.premiumGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 26,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: color,
        child: Text(
          name.isEmpty ? '?' : name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
