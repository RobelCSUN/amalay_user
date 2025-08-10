# amalay_user

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# Go to your project root
cd /Users/robelw/Documents/Amalay/code/amalay_user

# Clean Flutter build cache
flutter clean
flutter pub get

# Delete iOS build artifacts, Pods, and lock files
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec

# Reinstall Flutter dependencies
flutter pub get

# Go to iOS directory
cd ios

# Remove DerivedData (important)
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reinstall Pods with updated repo
pod install --repo-update




# How to run the app. (MVN clean type )
cd /Users/robelwoldegebriel/development/amalay/amalay_user
flutter clean
flutter pub get
cd /Users/robelwoldegebriel/development/amalay/amalay_user/ios

rm -rf Pods Podfile.lock
pod install --repo-update
cd /Users/robelwoldegebriel/development/amalay/amalay_user
# flutter run -d 00008110-001650311A44801E
flutter run --verbose


Delete ruuner:
flutter create .