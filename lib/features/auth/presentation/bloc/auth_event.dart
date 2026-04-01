part of 'auth_bloc.dart';

/// Base class for all authentication events.
sealed class AuthEvent extends Equatable {
  /// Creates an [AuthEvent].
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if the user is already onboarded.
final class AuthCheckRequested extends AuthEvent {
  /// Creates an [AuthCheckRequested] event.
  const AuthCheckRequested();
}

/// User submitted their LinkedIn profile URL or slug.
final class AuthProfileSubmitted extends AuthEvent {
  /// Creates an [AuthProfileSubmitted] event with the given [slug].
  const AuthProfileSubmitted(this.slug);

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
