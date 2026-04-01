part of 'auth_bloc.dart';

/// Possible authentication statuses.
enum AuthStatus {
  /// Initial state before any check has been performed.
  initial,

  /// An authentication operation is in progress.
  loading,

  /// The user has set up their profile.
  authenticated,

  /// The user has not set up their profile yet.
  unauthenticated,

  /// An error occurred.
  error,
}

/// Immutable state emitted by [AuthBloc].
final class AuthState extends Equatable {
  /// Creates an [AuthState].
  const AuthState({
    this.status = AuthStatus.initial,
    this.profile,
    this.errorMessage,
  });

  /// The current authentication status.
  final AuthStatus status;

  /// The user's profile, if available.
  final UserProfile? profile;

  /// A human-readable error message, if [status] is [AuthStatus.error].
  final String? errorMessage;

  /// Returns a copy of this [AuthState] with the given fields replaced.
  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
