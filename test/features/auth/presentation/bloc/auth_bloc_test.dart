import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';
import 'package:linked_here/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when not onboarded and '
        'no stored profile',
        build: () {
          when(
            () => mockAuthRepository.isOnboarded(),
          ).thenAnswer((_) async => false);
          when(
            () => mockAuthRepository.getStoredProfile(),
          ).thenAnswer((_) async => null);
          return AuthBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, needsLinkedInSlug] when not onboarded but '
        'has stored profile',
        build: () {
          const profile = UserProfile(
            displayName: 'Test User',
            email: 'test@example.com',
          );
          when(
            () => mockAuthRepository.isOnboarded(),
          ).thenAnswer((_) async => false);
          when(
            () => mockAuthRepository.getStoredProfile(),
          ).thenAnswer((_) async => profile);
          return AuthBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.needsLinkedInSlug,
            profile: UserProfile(
              displayName: 'Test User',
              email: 'test@example.com',
            ),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when onboarded with profile',
        build: () {
          const profile = UserProfile(
            displayName: 'Test User',
            email: 'test@example.com',
            linkedInSlug: 'test-user',
            linkedInUrl: 'https://www.linkedin.com/in/test-user',
          );
          when(
            () => mockAuthRepository.isOnboarded(),
          ).thenAnswer((_) async => true);
          when(
            () => mockAuthRepository.getStoredProfile(),
          ).thenAnswer((_) async => profile);
          return AuthBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.authenticated,
            profile: UserProfile(
              displayName: 'Test User',
              email: 'test@example.com',
              linkedInSlug: 'test-user',
              linkedInUrl: 'https://www.linkedin.com/in/test-user',
            ),
          ),
        ],
      );
    });

    group('AuthLinkedInSlugSubmitted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when slug saved successfully',
        build: () {
          const updatedProfile = UserProfile(
            displayName: 'Test User',
            email: 'test@example.com',
            linkedInSlug: 'test-user',
            linkedInUrl: 'https://www.linkedin.com/in/test-user',
          );
          when(
            () => mockAuthRepository.saveLinkedInSlug('test-user'),
          ).thenAnswer((_) async => updatedProfile);
          return AuthBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthLinkedInSlugSubmitted('test-user')),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(
            status: AuthStatus.authenticated,
            profile: UserProfile(
              displayName: 'Test User',
              email: 'test@example.com',
              linkedInSlug: 'test-user',
              linkedInUrl: 'https://www.linkedin.com/in/test-user',
            ),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when slug save fails',
        build: () {
          when(
            () => mockAuthRepository.saveLinkedInSlug('bad'),
          ).thenThrow(Exception('No profile found'));
          return AuthBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthLinkedInSlugSubmitted('bad')),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having(
                (s) => s.status,
                'status',
                AuthStatus.error,
              )
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                isNotNull,
              ),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when sign out requested',
        build: () {
          when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
          return AuthBloc(authRepository: mockAuthRepository);
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });
  });
}
