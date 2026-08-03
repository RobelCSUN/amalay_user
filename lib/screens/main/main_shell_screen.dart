// lib/screens/main/main_shell_screen.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:amalay_user/app/app_scope.dart';
import 'package:amalay_user/screens/discover/discover_screen.dart';
import 'package:amalay_user/screens/matches/matches_screen.dart';
import 'package:amalay_user/screens/profile/my_profile_screen.dart';
import 'package:amalay_user/theme/app_colors.dart';

/// Free-tier home: Discover, Matches, and your own Profile, over a shared
/// dusk gradient with a frosted-glass navigation bar.
class MainShellScreen extends StatefulWidget {
  final AppScope scope;

  const MainShellScreen({super.key, required this.scope});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.appBackgroundGradient,
          ),
        ),
        child: IndexedStack(
          index: _tab,
          children: [
            DiscoverScreen(
              userRepository: widget.scope.userRepository,
              matchRepository: widget.scope.matchRepository,
              safetyService: widget.scope.safetyService,
              locationService: widget.scope.locationService,
            ),
            MatchesScreen(
              matchRepository: widget.scope.matchRepository,
              safetyService: widget.scope.safetyService,
            ),
            MyProfileScreen(
              authService: widget.scope.authService,
              userRepository: widget.scope.userRepository,
              accountLifecycleService: widget.scope.accountLifecycleService,
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF241614).withValues(alpha: 0.72),
              border: const Border(
                top: BorderSide(color: AppColors.surfaceOutline),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (index) => setState(() => _tab = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.style_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.style, color: Colors.white),
                  label: 'Discover',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white70,
                  ),
                  selectedIcon: Icon(Icons.chat_bubble, color: Colors.white),
                  label: 'Matches',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: Colors.white70),
                  selectedIcon: Icon(Icons.person, color: Colors.white),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
