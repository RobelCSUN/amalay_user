import 'package:flutter/material.dart';

import 'package:amalay_user/app/app_scope.dart';
import 'package:amalay_user/onboarding/create_profile_screen.dart';
import 'package:amalay_user/screens/home/home_screen.dart';
import 'package:amalay_user/screens/main/main_shell_screen.dart';
import 'package:amalay_user/services/auth/phone_auth_screen.dart';
import 'package:amalay_user/widgets/legal/cookies_policy_dialog.dart';
import 'package:amalay_user/widgets/legal/privacy_policy_dialog.dart';
import 'package:amalay_user/widgets/legal/terms_of_service_dialog.dart';

class AppRoutes {
  static const home = '/';
  static const phoneAuth = '/auth/phone';
  static const createProfile = '/profile/create';
  static const mainShell = '/home/main';
  static const terms = '/legal/terms';
  static const privacy = '/legal/privacy';
  static const cookies = '/legal/cookies';

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    AppScope scope,
  ) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            authService: scope.authService,
            userRepository: scope.userRepository,
          ),
          settings: settings,
        );
      case phoneAuth:
        return MaterialPageRoute(
          builder: (_) => const PhoneAuthScreen(),
          settings: settings,
        );
      case createProfile:
        return MaterialPageRoute(
          builder: (_) => CreateProfileScreen(
            authService: scope.authService,
            userRepository: scope.userRepository,
          ),
          settings: settings,
        );
      case mainShell:
        return MaterialPageRoute(
          builder: (_) => MainShellScreen(scope: scope),
          settings: settings,
        );
      case terms:
        return MaterialPageRoute(
          builder: (_) => const TermsOfServiceScreen(),
          settings: settings,
        );
      case privacy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
          settings: settings,
        );
      case cookies:
        return MaterialPageRoute(
          builder: (_) => const CookiePolicyScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            authService: scope.authService,
            userRepository: scope.userRepository,
          ),
          settings: settings,
        );
    }
  }
}
