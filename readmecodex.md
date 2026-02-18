# readmecodex

Runbook for installing prerequisites and running this Flutter app on a real iPhone.

## One-time setup

### A) Mac prerequisites (do once)
1. Install Xcode from App Store.
2. Open Xcode once and accept license/components.
3. Install Flutter SDK.
4. Verify setup:
```bash
flutter doctor
```
5. Install CocoaPods (if missing):
```bash
sudo gem install cocoapods
```

### B) iPhone prerequisites (do once per iPhone)
1. Connect iPhone to Mac with cable.
2. Unlock iPhone and tap `Trust This Computer`.
3. Enable Developer Mode:
   `Settings > Privacy & Security > Developer Mode`
4. Restart iPhone if prompted.

### C) Xcode signing setup (do once per project)
1. Open workspace:
```bash
open ios/Runner.xcworkspace
```
2. In Xcode: `Xcode > Settings > Accounts` and add Apple ID.
3. Select blue `Runner` project icon (left sidebar).
4. Under `TARGETS`, select `Runner`.
5. Open `Signing & Capabilities`.
6. Set:
   - `Automatically manage signing` = ON
   - `Team` = your Apple team
7. If bundle ID is already used, change `Bundle Identifier` to a unique value.

### D) macOS permissions for debug mode (do once)
If you get `ptrace(PT_TRACE_ME): Operation not permitted`:

1. `System Settings > Privacy & Security > Automation`
   - Enable `Terminal -> Xcode`
   - Enable `Visual Studio Code -> Xcode` (if using VS Code terminal)
2. `System Settings > Privacy & Security > Developer Tools`
   - Enable `Terminal`
   - Enable `Visual Studio Code` (if used)

## First run from terminal

From project root:
```bash
cd /Users/robelwoldegebriel/Documents/development/amalay/amalay_user
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter devices
```

Run on iPhone:
```bash
flutter run -d 00008110-001650311A44801E
```

Keep iPhone unlocked while launching.

## If app is white screen in debug

1. Stop run with `Ctrl + C`.
2. Run once from Xcode (`Product > Run`) with iPhone selected.
3. Retry:
```bash
flutter run -d 00008110-001650311A44801E
```

## Release run (no debug attach needed)

Use this when debug attach is blocked:
```bash
flutter run --release -d 00008110-001650311A44801E
```

## Daily commands

Normal debug run:
```bash
flutter run -d 00008110-001650311A44801E
```

Full clean rebuild:
```bash
flutter clean
flutter pub get
cd ios && rm -rf Pods Podfile.lock && pod install --repo-update && cd ..
flutter run -d 00008110-001650311A44801E
```

Release run:
```bash
flutter run --release -d 00008110-001650311A44801E
```
