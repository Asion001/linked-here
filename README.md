# Linked Here

Find nearby LinkedIn profiles using Bluetooth Low Energy.

Linked Here lets you discover other LinkedIn users around you in
real time. Sign in with LinkedIn, enter your profile URL, and the app
broadcasts your slug over BLE while scanning for others doing the same.
Tap a discovered profile to open it on LinkedIn.

## Features

- **LinkedIn OAuth** -- sign in with your LinkedIn account via OIDC.
- **BLE advertising** -- broadcast your LinkedIn slug as a Peripheral.
- **BLE scanning** -- discover nearby profiles as a Central.
- **Tap to connect** -- open any discovered profile directly on LinkedIn.
- **Material 3** -- clean UI with LinkedIn-blue color seed, light and dark
  themes.

## Screenshots

_Coming soon._

## Architecture

Feature-based layers with `flutter_bloc` for state management:

```
lib/
  core/
    constants/      # BLE UUIDs, LinkedIn config, pref keys
    theme/          # Material 3 light/dark themes
    utils/          # LinkedIn URL parsing & validation
    widgets/        # Shared reusable widgets
  features/
    auth/
      data/         # AuthRepository, UserProfile model
      presentation/ # AuthBloc, LoginScreen, ProfileSetupScreen
    discovery/
      data/         # BleRepository (Central + Peripheral)
      presentation/ # DiscoveryBloc, DiscoveryScreen
    settings/
      presentation/ # SettingsScreen
  app.dart          # MaterialApp with MultiBlocProvider
  main.dart         # Entry point
```

## Tech stack

| Layer            | Package                                                                 |
| ---------------- | ----------------------------------------------------------------------- |
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) 9.x              |
| BLE              | [bluetooth_low_energy](https://pub.dev/packages/bluetooth_low_energy) 6.x |
| Auth             | [flutter_appauth](https://pub.dev/packages/flutter_appauth) 12.x       |
| Persistence      | [shared_preferences](https://pub.dev/packages/shared_preferences) 2.x  |
| Permissions      | [permission_handler](https://pub.dev/packages/permission_handler) 12.x  |
| URL launcher     | [url_launcher](https://pub.dev/packages/url_launcher) 6.x              |
| Lint             | [very_good_analysis](https://pub.dev/packages/very_good_analysis) 10.x |

## Prerequisites

- Flutter SDK >= 3.11
- Android minSdk 24 (Android 7.0+)
- iOS 13+
- A LinkedIn OAuth app with:
  - Client ID set in `lib/core/constants/app_constants.dart`
  - Redirect URI: `dev.asion.linkedhere://oauth2callback`

## Getting started

```bash
# Clone the repo
git clone https://github.com/Asion001/linked-here.git
cd linked-here

# Install dependencies
flutter pub get

# Run on a connected device (BLE requires a real device)
flutter run
```

## Configuration

Set your LinkedIn OAuth credentials in
`lib/core/constants/app_constants.dart`:

```dart
abstract final class LinkedInConfig {
  static const clientId = 'YOUR_CLIENT_ID';
  // ...
}
```

The redirect scheme is configured in:

- **Android**: `android/app/build.gradle.kts` (`appAuthRedirectScheme`)
- **iOS**: `ios/Runner/Info.plist` (`CFBundleURLSchemes`)

## Running tests

```bash
flutter test
```

## Linting

```bash
flutter analyze
dart format --set-exit-if-changed .
```

## CI/CD

GitHub Actions workflows are included:

| Workflow                                   | Trigger          | Description                                |
| ------------------------------------------ | ---------------- | ------------------------------------------ |
| [CI](.github/workflows/ci.yml)             | push / PR        | Analyze, format check, run tests           |
| [Release](.github/workflows/release.yml)   | tag `v*`         | Build APK + IPA, create GitHub Release     |

## How it works

1. User signs in with LinkedIn via OAuth/OIDC.
2. User enters their LinkedIn profile URL (the vanity slug).
3. The app starts a BLE Peripheral that advertises a custom GATT service
   containing the LinkedIn slug in a read-only characteristic.
4. Simultaneously, the app starts a BLE Central that scans for nearby
   devices advertising the same service UUID.
5. When a device is found, the Central connects, reads the slug
   characteristic, and displays the discovered profile.
6. Tapping a profile opens the full LinkedIn URL in the browser.

## Permissions

| Platform | Permission                            | Why                              |
| -------- | ------------------------------------- | -------------------------------- |
| Android  | `BLUETOOTH_SCAN`                      | Discover nearby BLE devices      |
| Android  | `BLUETOOTH_ADVERTISE`                 | Broadcast your profile           |
| Android  | `BLUETOOTH_CONNECT`                   | Read GATT characteristics        |
| Android  | `ACCESS_FINE_LOCATION`                | Required for BLE scanning        |
| iOS      | `NSBluetoothAlwaysUsageDescription`   | Bluetooth access prompt          |

## License

This project is not yet published under a specific license.
