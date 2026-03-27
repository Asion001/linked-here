part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if the user is already signed in and onboarded.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User tapped "Sign in with LinkedIn".
final class AuthLinkedInSignInRequested extends AuthEvent {
  const AuthLinkedInSignInRequested();
}

/// User submitted their LinkedIn profile URL during onboarding.
final class AuthLinkedInSlugSubmitted extends AuthEvent {
  const AuthLinkedInSlugSubmitted(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}

/// User requested sign out.
final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
