import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:linked_here/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for the authenticated user's profile.
class UserProfile {
  /// Creates a [UserProfile].
  const UserProfile({
    required this.displayName,
    required this.email,
    this.linkedInSlug,
    this.linkedInUrl,
    this.profilePictureUrl,
  });

  /// The user's full display name from LinkedIn.
  final String displayName;

  /// The user's email address from LinkedIn.
  final String email;

  /// The LinkedIn vanity slug (e.g. `john-doe`), entered manually.
  final String? linkedInSlug;

  /// The full LinkedIn profile URL built from the [linkedInSlug].
  final String? linkedInUrl;

  /// URL of the user's LinkedIn profile picture.
  final String? profilePictureUrl;

  /// Returns a copy of this [UserProfile] with the given fields replaced.
  UserProfile copyWith({
    String? displayName,
    String? email,
    String? linkedInSlug,
    String? linkedInUrl,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      linkedInSlug: linkedInSlug ?? this.linkedInSlug,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}

/// Repository handling LinkedIn OAuth2 authentication and local
/// profile persistence.
class AuthRepository {
  /// Creates an [AuthRepository].
  ///
  /// All parameters are optional and injectable for testing.
  AuthRepository({
    FlutterAppAuth? appAuth,
    http.Client? httpClient,
    SharedPreferencesAsync? prefs,
  }) : _appAuth = appAuth ?? const FlutterAppAuth(),
       _httpClient = httpClient ?? http.Client(),
       _prefs = prefs ?? SharedPreferencesAsync();

  final FlutterAppAuth _appAuth;
  final http.Client _httpClient;
  final SharedPreferencesAsync _prefs;

  /// Attempts LinkedIn OIDC sign-in and returns the user profile.
  ///
  /// Throws [FlutterAppAuthUserCancelledException] if the user cancels.
  /// Throws [FlutterAppAuthPlatformException] on OAuth errors.
  Future<UserProfile> signInWithLinkedIn() async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        LinkedInConfig.clientId,
        LinkedInConfig.redirectUrl,
        discoveryUrl: LinkedInConfig.discoveryUrl,
        scopes: LinkedInConfig.scopes,
      ),
    );

    final accessToken = result.accessToken;
    if (accessToken == null) {
      throw Exception('No access token received from LinkedIn');
    }

    // Fetch user info from LinkedIn
    final response = await _httpClient.get(
      Uri.parse(LinkedInConfig.userinfoUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch user info: ${response.statusCode}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Unknown';
    final email = data['email'] as String? ?? '';
    final picture = data['picture'] as String?;

    final profile = UserProfile(
      displayName: name,
      email: email,
      profilePictureUrl: picture,
    );

    await _saveProfile(profile);
    return profile;
  }

  /// Saves the LinkedIn slug after the user enters it during onboarding.
  Future<UserProfile> saveLinkedInSlug(String slug) async {
    final profile = await getStoredProfile();
    if (profile == null) {
      throw StateError('No profile found. Please sign in first.');
    }

    final updated = profile.copyWith(
      linkedInSlug: slug,
      linkedInUrl: 'https://www.linkedin.com/in/$slug',
    );

    await _saveProfile(updated);
    await _prefs.setBool(PrefKeys.isOnboarded, true);
    return updated;
  }

  /// Returns the locally stored profile, or null if not signed in.
  Future<UserProfile?> getStoredProfile() async {
    final name = await _prefs.getString(PrefKeys.displayName);
    if (name == null) return null;

    return UserProfile(
      displayName: name,
      email: await _prefs.getString(PrefKeys.email) ?? '',
      linkedInSlug: await _prefs.getString(PrefKeys.linkedinSlug),
      linkedInUrl: await _prefs.getString(PrefKeys.linkedinUrl),
      profilePictureUrl: await _prefs.getString(PrefKeys.profilePictureUrl),
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
    await _prefs.remove(PrefKeys.email);
    await _prefs.remove(PrefKeys.linkedinSlug);
    await _prefs.remove(PrefKeys.linkedinUrl);
    await _prefs.remove(PrefKeys.profilePictureUrl);
  }

  Future<void> _saveProfile(UserProfile profile) async {
    await _prefs.setString(PrefKeys.displayName, profile.displayName);
    await _prefs.setString(PrefKeys.email, profile.email);
    if (profile.profilePictureUrl != null) {
      await _prefs.setString(
        PrefKeys.profilePictureUrl,
        profile.profilePictureUrl!,
      );
    }
    if (profile.linkedInSlug != null) {
      await _prefs.setString(
        PrefKeys.linkedinSlug,
        profile.linkedInSlug!,
      );
    }
    if (profile.linkedInUrl != null) {
      await _prefs.setString(
        PrefKeys.linkedinUrl,
        profile.linkedInUrl!,
      );
    }
  }
}
