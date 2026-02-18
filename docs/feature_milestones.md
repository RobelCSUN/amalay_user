# Feature Milestones: Auth -> Onboarding -> Profile Home

This checklist is ordered for lowest risk and fastest delivery.

## Milestone 1: Session Gate Foundation

Goal: Centralize startup routing so app launch behavior is deterministic.

Scope:
- Add `SessionGate` as initial app entry route.
- Route by session state:
  - logged out -> Auth Home
  - logged in + incomplete profile -> Profile Completion
  - logged in + complete profile -> Profile Home
- Move launch/session checks out of Home UI.

Definition of Done:
- Fresh launch always resolves to one correct screen.
- No navigation loop or double-push.
- Loading state is shown only during session check.

Risks:
- race conditions from auth state streams
- stale user state after sign-out

---

## Milestone 2: Post-Auth Persistence Baseline

Goal: Persist user record immediately after authentication.

Scope:
- After auth success, write minimal `users/{uid}` immediately.
- Track:
  - `uid`
  - `authProviders`
  - `createdAt` (first time)
  - `lastLoginAt` (every login)
  - `profileComplete=false` until onboarding done
  - `onboardingStep`

Definition of Done:
- User doc exists even if onboarding is abandoned.
- Returning unfinished users can resume.
- No auth success without corresponding user doc write attempt.

Risks:
- partial writes on intermittent network
- duplicate writes if auth callback fires multiple times

---

## Milestone 3: Profile Completion V1 (Required Fields)

Goal: Ship a minimal but complete onboarding flow.

Scope (required fields only):
- first name
- birth date
- gender
- looking for
- city
- bio
- minimum photos

Behavior:
- save at each step/screen
- persist `onboardingStep` for resume
- validate before final completion
- set `profileComplete=true` only at the end

Definition of Done:
- User can leave app mid-onboarding and resume correctly.
- User cannot reach Profile Home until required fields are complete.
- All required fields are persisted in Firestore.

Risks:
- validation inconsistency between UI and backend rules
- broken resume index if step IDs change

---

## Milestone 4: Profile Home + Strict Guard

Goal: Enforce long-term landing behavior.

Scope:
- Add `ProfileHomeScreen`.
- Startup guard always sends incomplete users to onboarding.
- Completed users land directly on Profile Home.
- Logout returns to Auth Home from any authenticated route.

Definition of Done:
- Relaunch behavior is stable across app restarts.
- Manual logout always clears route stack correctly.
- Incomplete profile users cannot bypass onboarding.

Risks:
- guard checks only at launch but not after in-app state changes

---

## Milestone 5: Auth Home Simplification (Final UX)

Goal: Keep entry flow minimal and clear.

Scope:
- Home screen copy focuses on "Continue".
- No explicit Sign In vs Create Account split.
- Show provider buttons only (Apple, Google, Phone, Facebook).
- Elegant visual hierarchy, minimal cognitive load.

Definition of Done:
- Provider tap is the only primary action.
- New and returning users both work through same entry path.
- UI text no longer creates account/sign-in mode confusion.

Risks:
- unclear provider affordance if icon contrast is low on hero image

---

## Milestone 6: Facebook Auth Integration

Goal: Add fourth provider without destabilizing existing flow.

Scope:
- Implement Facebook auth in `AuthService`.
- iOS/Android config and callback URL setup.
- Include provider in same unified post-auth pipeline.

Definition of Done:
- Facebook auth works on real iPhone and Android.
- Facebook users follow same onboarding/profile routing as others.
- Proper error handling for cancellation and config issues.

Risks:
- platform setup mismatch
- SDK/version compatibility

---

## Milestone 7: Account Linking Hardening

Goal: Prevent duplicate accounts for same user across providers.

Scope:
- Handle collisions when same email/phone appears with different provider.
- Link credentials where possible.
- Add clear fallback/error UX when relink is required.

Definition of Done:
- One user maps to one app profile whenever linkable.
- Known Firebase linking errors are handled predictably.
- Duplicate user-doc creation is minimized/blocked.

Risks:
- provider-specific constraints (Apple relay emails, phone-only identities)

---

## Milestone 8: Security Rules + QA Hardening

Goal: Lock data and validate production readiness.

Scope:
- Firestore rules for user-owned reads/writes only.
- Validate partial onboarding writes allowed only for own uid.
- End-to-end test matrix on real device.

Definition of Done:
- Rules prevent cross-user access.
- Onboarding/profile writes work only for authenticated owner.
- Smoke tests pass for all auth providers and resume flows.

Risks:
- rules too strict causing hidden client failures

---

## Recommended Features (Post-Core)

1. Progressive profiling:
- Keep V1 short; ask advanced fields later in profile editing.

2. Profile draft autosave indicator:
- Small “Saved” feedback after each step commit.

3. Analytics events:
- auth started/succeeded/cancelled
- onboarding step completion/drop-off
- profile completion rate by provider

4. Anti-abuse basics:
- photo moderation pipeline placeholder
- rate limits for OTP resend

5. Accessibility pass:
- dynamic text size checks
- high-contrast fallback for icon buttons on image backgrounds

---

## Execution Priority (Recommended)

1. Milestone 1
2. Milestone 2
3. Milestone 3
4. Milestone 4
5. Milestone 5
6. Milestone 6
7. Milestone 7
8. Milestone 8

