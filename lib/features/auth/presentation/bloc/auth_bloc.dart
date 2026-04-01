import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc managing profile setup state.
///
/// Handles onboarding checks, profile submission, and sign-out.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Creates an [AuthBloc].
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthProfileSubmitted>(_onProfileSubmitted);
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
        emit(state.copyWith(status: AuthStatus.unauthenticated));
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

  Future<void> _onProfileSubmitted(
    AuthProfileSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final profile = await _authRepository.saveProfile(event.slug);
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
