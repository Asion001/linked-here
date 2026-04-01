import 'package:linked_here/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for the user's profile.
class UserProfile {
  /// Creates a [UserProfile].
  const UserProfile({
    required this.displayName,
    required this.linkedInSlug,
    required this.linkedInUrl,
  });

  /// The display name derived from the LinkedIn slug.
  final String displayName;

  /// The LinkedIn vanity slug (e.g. `john-doe`).
  final String linkedInSlug;

  /// The full LinkedIn profile URL built from the [linkedInSlug].
  final String linkedInUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          linkedInSlug == other.linkedInSlug &&
          linkedInUrl == other.linkedInUrl;

  @override
  int get hashCode =>
      displayName.hashCode ^ linkedInSlug.hashCode ^ linkedInUrl.hashCode;
}

/// Repository handling local profile persistence.
class AuthRepository {
  /// Creates an [AuthRepository].
  ///
  /// [prefs] is optional and injectable for testing.
  AuthRepository({SharedPreferencesAsync? prefs})
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  /// Saves a LinkedIn profile from the given [slug] and returns the
  /// created [UserProfile].
  Future<UserProfile> saveProfile(String slug) async {
    final displayName = _displayNameFromSlug(slug);
    final linkedInUrl = '${LinkedInConfig.profileBaseUrl}$slug';

    final profile = UserProfile(
      displayName: displayName,
      linkedInSlug: slug,
      linkedInUrl: linkedInUrl,
    );

    await _prefs.setString(PrefKeys.displayName, profile.displayName);
    await _prefs.setString(PrefKeys.linkedinSlug, profile.linkedInSlug);
    await _prefs.setString(PrefKeys.linkedinUrl, profile.linkedInUrl);
    await _prefs.setBool(PrefKeys.isOnboarded, true);

    return profile;
  }

  /// Returns the locally stored profile, or `null` if none exists.
  Future<UserProfile?> getStoredProfile() async {
    final slug = await _prefs.getString(PrefKeys.linkedinSlug);
    if (slug == null) return null;

    return UserProfile(
      displayName:
          await _prefs.getString(PrefKeys.displayName) ??
          _displayNameFromSlug(slug),
      linkedInSlug: slug,
      linkedInUrl:
          await _prefs.getString(PrefKeys.linkedinUrl) ??
          '${LinkedInConfig.profileBaseUrl}$slug',
    );
  }

  /// Whether the user has completed onboarding.
  Future<bool> isOnboarded() async {
    return await _prefs.getBool(PrefKeys.isOnboarded) ?? false;
  }

  /// Signs out and clears stored data.
  Future<void> signOut() async {
    await _prefs.remove(PrefKeys.isOnboarded);
    await _prefs.remove(PrefKeys.displayName);
    await _prefs.remove(PrefKeys.linkedinSlug);
    await _prefs.remove(PrefKeys.linkedinUrl);
  }

  /// Converts a slug like `john-doe` to a display name like `John Doe`.
  static String _displayNameFromSlug(String slug) {
    return slug
        .split('-')
        .map(
          (word) =>
              word.isEmpty
                  ? ''
                  : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
