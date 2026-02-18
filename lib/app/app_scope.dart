import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/auth/auth_service.dart';

class AppScope {
  final AuthService authService;
  final UserRepository userRepository;

  AppScope({AuthService? authService, UserRepository? userRepository})
    : authService = authService ?? AuthService(),
      userRepository = userRepository ?? UserRepository();
}
