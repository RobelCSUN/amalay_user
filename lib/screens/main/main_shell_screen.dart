// lib/screens/main/main_shell_screen.dart
import 'package:flutter/material.dart';

import 'package:amalay_user/app/app_scope.dart';
import 'package:amalay_user/screens/discover/discover_screen.dart';
import 'package:amalay_user/screens/matches/matches_screen.dart';
import 'package:amalay_user/screens/profile/my_profile_screen.dart';
import 'package:amalay_user/theme/app_colors.dart';

/// Free-tier home: Discover, Matches, and your own Profile.
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
      backgroundColor: const Color(0xFF241614),
      body: IndexedStack(
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: const Color(0xFF2E1B18),
        indicatorColor: AppColors.accentRose.withValues(alpha: 0.35),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_outline, color: Colors.white70),
            selectedIcon: Icon(Icons.favorite, color: Colors.white),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.white70),
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
    );
  }
}
