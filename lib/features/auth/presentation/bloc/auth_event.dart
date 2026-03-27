part of 'auth_bloc.dart';

/// Base class for all authentication events.
sealed class AuthEvent extends Equatable {
  /// Creates an [AuthEvent].
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if the user is already signed in and onboarded.
final class AuthCheckRequested extends AuthEvent {
  /// Creates an [AuthCheckRequested] event.
  const AuthCheckRequested();
}

/// User tapped "Sign in with LinkedIn".
final class AuthLinkedInSignInRequested extends AuthEvent {
  /// Creates an [AuthLinkedInSignInRequested] event.
  const AuthLinkedInSignInRequested();
}

/// User submitted their LinkedIn profile URL during onboarding.
final class AuthLinkedInSlugSubmitted extends AuthEvent {
  /// Creates an [AuthLinkedInSlugSubmitted] event with the given [slug].
  const AuthLinkedInSlugSubmitted(this.slug);

  /// The LinkedIn vanity slug the user entered.
  final String slug;

  @override
  List<Object?> get props => [slug];
}

/// User requested sign out.
final class AuthSignOutRequested extends AuthEvent {
  /// Creates an [AuthSignOutRequested] event.
  const AuthSignOutRequested();
}
