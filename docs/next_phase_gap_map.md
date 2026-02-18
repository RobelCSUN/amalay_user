# Gap Map: Current State vs Target State

## Current State (as of now)

- Auth providers implemented:
  - Apple
  - Google
  - Phone
- Facebook auth:
  - Not implemented yet

- Home screen UX:
  - Provider buttons present
  - Sign in/create wording still partially mixed in flow

- Routing/entry:
  - Home screen currently drives session handling + profile routing logic
  - No dedicated `SessionGate` screen yet

- Profile onboarding:
  - Single-step display name only (`CreateProfileScreen`)
  - No multi-step dating profile flow yet

- Persistence:
  - `profileComplete` exists
  - Basic user doc lifecycle exists
  - No detailed dating profile schema implemented yet

- Returning user behavior:
  - Basic behavior exists
  - Needs stricter startup routing guarantees using dedicated gate

---

## Target State

- 4 providers active: Apple, Google, Phone, Facebook
- Home screen is minimalist provider-first (no sign-in/create mode complexity)
- Firestore user document is created/updated immediately after auth success, even before profile completion
- SessionGate decides route at startup:
  - logged out -> Auth Home
  - logged in + incomplete profile -> Profile Completion
  - logged in + complete profile -> Profile Home
- Multi-step profile completion with save/resume
- Final profile completion flag and step-tracking persisted in Firestore
- Logout is only intentional path back to auth home

---

## Recommended New Modules (No code yet, planning only)

- `lib/screens/session/session_gate_screen.dart`
- `lib/screens/profile/profile_completion_flow_screen.dart`
- `lib/screens/profile/profile_home_screen.dart`
- `lib/models/profile_onboarding_state.dart`
- `lib/repositories/profile_repository.dart` (optional split from user repository)

---

## Risks to Manage During Implementation

1. Provider linking conflicts (same email across providers).
2. Interrupted onboarding flow (must resume reliably).
3. Partial writes and validation consistency.
4. Navigation loops if profileComplete sync is delayed.
5. Platform config complexity for Facebook auth.

---

## Done Definition for Next Phase

1. Fresh install -> auth -> onboarding -> profile home works end-to-end.
2. App relaunch resumes correct page without flicker/loop.
3. Logout returns to auth home from any authenticated state.
4. All 4 providers tested on real iPhone.
5. Database writes happen immediately post-auth; incomplete users still have persisted user docs and resume state.
