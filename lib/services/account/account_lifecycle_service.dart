// lib/services/account/account_lifecycle_service.dart
import 'package:cloud_functions/cloud_functions.dart';

/// Self-service account lifecycle. Both actions require a recent sign-in
/// (enforced server-side); callers should prompt re-authentication when a
/// `failed-precondition` error surfaces.
class AccountLifecycleService {
  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<void> deactivateMyAccount() async {
    await _functions.httpsCallable('deactivateMyAccount').call();
  }

  Future<void> requestAccountDeletion() async {
    await _functions.httpsCallable('requestAccountDeletion').call();
  }
}
