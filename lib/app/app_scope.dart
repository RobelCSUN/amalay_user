import 'package:amalay_user/repositories/match_repository.dart';
import 'package:amalay_user/repositories/user_repository.dart';
import 'package:amalay_user/services/account/account_lifecycle_service.dart';
import 'package:amalay_user/services/admin/admin_service.dart';
import 'package:amalay_user/services/auth/auth_service.dart';
import 'package:amalay_user/services/geo/location_service.dart';
import 'package:amalay_user/services/safety/safety_service.dart';

class AppScope {
  final AuthService authService;
  final UserRepository userRepository;
  final MatchRepository matchRepository;
  final SafetyService safetyService;
  final AccountLifecycleService accountLifecycleService;
  final LocationService locationService;
  final AdminService adminService;

  AppScope({
    AuthService? authService,
    UserRepository? userRepository,
    MatchRepository? matchRepository,
    SafetyService? safetyService,
    AccountLifecycleService? accountLifecycleService,
    LocationService? locationService,
    AdminService? adminService,
  }) : authService = authService ?? AuthService(),
       userRepository = userRepository ?? UserRepository(),
       matchRepository = matchRepository ?? MatchRepository(),
       safetyService = safetyService ?? SafetyService(),
       accountLifecycleService =
           accountLifecycleService ?? AccountLifecycleService(),
       locationService = locationService ?? LocationService(),
       adminService = adminService ?? AdminService();
}
