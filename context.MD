# Amalay User App Context

## Current Goal State
- Flutter iOS-first dating app entry experience with:
  - full-screen hero background image
  - bottom authentication controls
  - Apple / Google / Phone auth options
  - profile completion flow after auth

## Architecture Overview
- `lib/main.dart`
  - App bootstrap, Firebase initialization, auth warmup trigger, and `AppScope` creation.
- `lib/app/app_scope.dart`
  - Dependency boundary for shared services (`AuthService`, `UserRepository`).
- `lib/app/app.dart`
  - Root `MaterialApp` setup, theme, and centralized route wiring.
- `lib/app/app_routes.dart`
  - Named route constants and `onGenerateRoute` for home/auth/profile/legal screens.
- `lib/theme/`
  - `app_theme.dart`: shared ThemeData.
  - `app_colors.dart`: palette tokens.
  - `app_text_styles.dart`: shared text styles.
- `lib/widgets/themed_background.dart`
  - Reusable background shell with hero image + overlay.
- `lib/screens/home/home_screen.dart`
  - Main state coordinator for:
    - auth session stream
    - user doc bootstrap
    - profile-complete gate
    - rendering signed-out vs signed-in content
- `lib/widgets/auth_card.dart`
  - Signed-out UI composition and auth entry controls.
- Legacy `lib/widgets/sign_in/*` widgets were removed (not part of active UI path).
- `lib/services/auth/auth_service.dart`
  - Google/Apple sign-in + sign-out behavior.
- `lib/services/auth/phone_auth_screen.dart`
  - Phone number auth flow + SMS verification.
- `lib/repositories/user_repository.dart`
  - Firestore user doc lifecycle (`ensureUserDoc`, `touchLogin`, `isProfileComplete`, etc).
- `lib/onboarding/create_profile_screen.dart`
  - Minimal profile completion step.

## Current Home UX (Important)
- `AuthCard` is in **mode-toggle** style:
  - `isSignUp` and `onToggleCopy` are active.
  - A mode orb is shown above social icons.
  - Apple / Google / Phone are icon-only circular buttons.
- Background mode switching:
  - `ThemedBackground(... isCreateMode: _isSignUp ...)`
  - Create mode image: `assets/images/habesha_couple_hero.jpg`
  - Login mode image (optional): `assets/images/habesha_couple_login.jpg`
  - If login image missing, fallback to create image.

## Asset Paths
- Home hero image required:
  - `assets/images/habesha_couple_hero.jpg`
- Optional login variant:
  - `assets/images/habesha_couple_login.jpg`
- Assets declared in `pubspec.yaml`:
  - `assets/images/`

## Auth / Data Flow
1. App starts -> Firebase init -> warmup runs.
2. `AppScope` is created and injected via app routes.
3. `HomeScreen` listens to `authStateChanges`.
4. On signed-in:
   - ensure user doc
   - touch login
   - check profile completeness
5. If incomplete -> push `CreateProfileScreen` via named route.
6. If complete -> show `SignedInCard`.

## Current Quality Status
- `flutter analyze`: clean.
- `flutter test`: baseline tests pass.

## Known Improvements (Next Iteration)
- Split `HomeScreen` orchestration into controller/state layer (Riverpod/BLoC/ChangeNotifier) to reduce UI-state coupling.
- Refine `AuthCard` into smaller widgets:
  - hero text block
  - mode toggle orb
  - provider icon row
  - legal text block
- Replace placeholder Google mark with a proper brand-safe asset/SVG icon.

## Commands
- Run on iPhone:
```bash
flutter run -d 00008110-001650311A44801E
```
- Release run:
```bash
flutter run --release -d 00008110-001650311A44801E
```
- Rebuild iOS deps:
```bash
flutter clean
flutter pub get
cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ..
```

## Collaboration Notes
- Do not overwrite `README.md` unless explicitly requested.
- Use `readmecodex.md` for iPhone setup/runbook instructions.
- Keep hero/home design changes aligned with current romantic visual direction and icon-only provider row.
