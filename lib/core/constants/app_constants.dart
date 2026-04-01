/// App-wide constants for LinkedHere.
library;

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// LinkedIn configuration constants.
abstract final class LinkedInConfig {
  /// LinkedIn profile base URL.
  static const String profileBaseUrl = 'https://www.linkedin.com/in/';
}

/// BLE configuration constants.
abstract final class BleConfig {
  /// Custom service UUID for LinkedHere BLE service.
  /// Generated from a UUID v4 namespace.
  static final UUID serviceUuid = UUID.fromString(
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d',
  );

  /// Characteristic UUID for the LinkedIn slug.
  static final UUID slugCharacteristicUuid = UUID.fromString(
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5e',
  );

  /// Characteristic UUID for the display name.
  static final UUID nameCharacteristicUuid = UUID.fromString(
    'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5f',
  );

  /// Scan duration in seconds before auto-stopping.
  static const int scanDurationSeconds = 15;
}

/// SharedPreferences keys.
abstract final class PrefKeys {
  /// Whether the user has completed onboarding.
  static const String isOnboarded = 'is_onboarded';

  /// The user's LinkedIn slug (vanity name).
  static const String linkedinSlug = 'linkedin_slug';

  /// The user's LinkedIn profile URL.
  static const String linkedinUrl = 'linkedin_url';

  /// The user's display name derived from the LinkedIn slug.
  static const String displayName = 'display_name';
}
