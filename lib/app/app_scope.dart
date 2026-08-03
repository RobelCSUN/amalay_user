import 'package:amalay_user/repositories/match_repository.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/auth/auth_service.dart';

class AppScope {
  final AuthService authService;
  final UserRepository userRepository;
  final MatchRepository matchRepository;

  AppScope({
    AuthService? authService,
    UserRepository? userRepository,
    MatchRepository? matchRepository,
  }) : authService = authService ?? AuthService(),
       userRepository = userRepository ?? UserRepository(),
       matchRepository = matchRepository ?? MatchRepository();
}
