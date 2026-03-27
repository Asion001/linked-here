import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc managing authentication state and LinkedIn OAuth flow.
///
/// Handles sign-in, sign-out, onboarding checks, and LinkedIn slug
/// submission.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc].
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLinkedInSignInRequested>(_onLinkedInSignInRequested);
    on<AuthLinkedInSlugSubmitted>(_onLinkedInSlugSubmitted);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final isOnboarded = await _authRepository.isOnboarded();
      if (!isOnboarded) {
        final profile = await _authRepository.getStoredProfile();
        if (profile != null) {
          emit(
            state.copyWith(
              status: AuthStatus.needsLinkedInSlug,
              profile: profile,
            ),
          );
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
        return;
      }

      final profile = await _authRepository.getStoredProfile();
      if (profile != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
          ),
        );
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLinkedInSignInRequested(
    AuthLinkedInSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final profile = await _authRepository.signInWithLinkedIn();
      emit(
        state.copyWith(
          status: AuthStatus.needsLinkedInSlug,
          profile: profile,
        ),
      );
    } on FlutterAppAuthUserCancelledException {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLinkedInSlugSubmitted(
    AuthLinkedInSlugSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final profile = await _authRepository.saveLinkedInSlug(event.slug);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          profile: profile,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
