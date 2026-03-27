/// Utility functions for LinkedIn URL parsing and validation.
library;

/// Extracts the LinkedIn slug from a full profile URL.
///
/// Returns `null` if the URL is not a valid LinkedIn profile URL.
///
/// Accepts formats like:
/// - `https://www.linkedin.com/in/john-doe`
/// - `https://linkedin.com/in/john-doe/`
/// - `linkedin.com/in/john-doe`
String? extractLinkedInSlug(String input) {
  final trimmed = input.trim();

  // Try to parse as URL first
  final pattern = RegExp(
    r'(?:https?://)?(?:www\.)?linkedin\.com/in/([a-zA-Z0-9\-]+)/?$',
  );
  final match = pattern.firstMatch(trimmed);
  if (match != null) {
    return match.group(1);
  }

  // If it looks like a bare slug (no slashes, valid characters)
  final slugPattern = RegExp(r'^[a-zA-Z0-9\-]{3,100}$');
  if (slugPattern.hasMatch(trimmed)) {
    return trimmed;
  }

  return null;
}

/// Builds a full LinkedIn profile URL from a slug.
String buildLinkedInUrl(String slug) {
  return 'https://www.linkedin.com/in/$slug';
}

/// Validates whether the given string is a valid LinkedIn profile URL
/// or slug.
bool isValidLinkedInInput(String input) {
  return extractLinkedInSlug(input) != null;
}
