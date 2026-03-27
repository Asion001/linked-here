import 'package:flutter_test/flutter_test.dart';
import 'package:linked_here/core/utils/linkedin_utils.dart';

void main() {
  group('extractLinkedInSlug', () {
    test('extracts slug from full https URL', () {
      expect(
        extractLinkedInSlug('https://www.linkedin.com/in/john-doe'),
        equals('john-doe'),
      );
    });

    test('extracts slug from URL with trailing slash', () {
      expect(
        extractLinkedInSlug('https://linkedin.com/in/john-doe/'),
        equals('john-doe'),
      );
    });

    test('extracts slug from URL without www', () {
      expect(
        extractLinkedInSlug('https://linkedin.com/in/jane123'),
        equals('jane123'),
      );
    });

    test('extracts slug from URL without protocol', () {
      expect(
        extractLinkedInSlug('linkedin.com/in/john-doe'),
        equals('john-doe'),
      );
    });

    test('returns bare slug when valid', () {
      expect(
        extractLinkedInSlug('john-doe'),
        equals('john-doe'),
      );
    });

    test('returns null for invalid input', () {
      expect(extractLinkedInSlug('not a url at all!'), isNull);
    });

    test('returns null for empty input', () {
      expect(extractLinkedInSlug(''), isNull);
    });

    test('returns null for too-short slug', () {
      expect(extractLinkedInSlug('ab'), isNull);
    });

    test('trims whitespace before parsing', () {
      expect(
        extractLinkedInSlug('  john-doe  '),
        equals('john-doe'),
      );
    });
  });

  group('buildLinkedInUrl', () {
    test('builds full URL from slug', () {
      expect(
        buildLinkedInUrl('john-doe'),
        equals('https://www.linkedin.com/in/john-doe'),
      );
    });
  });

  group('isValidLinkedInInput', () {
    test('returns true for valid URL', () {
      expect(
        isValidLinkedInInput('https://www.linkedin.com/in/john-doe'),
        isTrue,
      );
    });

    test('returns true for valid slug', () {
      expect(isValidLinkedInInput('john-doe'), isTrue);
    });

    test('returns false for invalid input', () {
      expect(isValidLinkedInInput('!!!'), isFalse);
    });
  });
}
