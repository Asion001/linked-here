import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';
import 'package:linked_here/features/discovery/data/ble_repository.dart';
import 'package:linked_here/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockBleRepository extends Mock implements BleRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockBleRepository mockBleRepository;
  late MockAuthRepository mockAuthRepository;
  late StreamController<DiscoveredProfile> profileStreamController;

  setUp(() {
    mockBleRepository = MockBleRepository();
    mockAuthRepository = MockAuthRepository();
    profileStreamController = StreamController<DiscoveredProfile>.broadcast();

    when(
      () => mockBleRepository.discoveredProfiles,
    ).thenAnswer((_) => profileStreamController.stream);
    when(() => mockBleRepository.startScanning()).thenAnswer((_) async {});
    when(() => mockBleRepository.stopScanning()).thenAnswer((_) async {});
    when(
      () => mockBleRepository.startAdvertising(
        slug: any(named: 'slug'),
        displayName: any(named: 'displayName'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockBleRepository.stopAdvertising()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await profileStreamController.close();
  });

  group('DiscoveryBloc', () {
    group('DiscoveryStarted', () {
      blocTest<DiscoveryBloc, DiscoveryState>(
        'emits [scanning] and starts scanning and advertising',
        build: () {
          when(() => mockAuthRepository.getStoredProfile()).thenAnswer(
            (_) async => const UserProfile(
              displayName: 'Test',
              email: 'test@test.com',
              linkedInSlug: 'test-user',
            ),
          );
          return DiscoveryBloc(
            bleRepository: mockBleRepository,
            authRepository: mockAuthRepository,
          );
        },
        act: (bloc) => bloc.add(const DiscoveryStarted()),
        expect: () => [
          const DiscoveryState(status: DiscoveryStatus.scanning),
        ],
        verify: (_) {
          verify(() => mockBleRepository.startScanning()).called(1);
          verify(
            () => mockBleRepository.startAdvertising(
              slug: 'test-user',
              displayName: 'Test',
            ),
          ).called(1);
        },
      );

      blocTest<DiscoveryBloc, DiscoveryState>(
        'emits [error] when scanning fails',
        build: () {
          when(
            () => mockAuthRepository.getStoredProfile(),
          ).thenAnswer((_) async => null);
          when(
            () => mockBleRepository.startScanning(),
          ).thenThrow(Exception('BLE unavailable'));
          return DiscoveryBloc(
            bleRepository: mockBleRepository,
            authRepository: mockAuthRepository,
          );
        },
        act: (bloc) => bloc.add(const DiscoveryStarted()),
        expect: () => [
          const DiscoveryState(status: DiscoveryStatus.scanning),
          isA<DiscoveryState>()
              .having(
                (s) => s.status,
                'status',
                DiscoveryStatus.error,
              )
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                isNotNull,
              ),
        ],
      );
    });

    group('DiscoveryStopped', () {
      blocTest<DiscoveryBloc, DiscoveryState>(
        'emits [idle] and stops scanning',
        build: () => DiscoveryBloc(
          bleRepository: mockBleRepository,
          authRepository: mockAuthRepository,
        ),
        act: (bloc) => bloc.add(const DiscoveryStopped()),
        expect: () => [
          const DiscoveryState(),
        ],
        verify: (_) {
          // Called once in _onStopped and once in close().
          verify(() => mockBleRepository.stopScanning()).called(2);
          verify(() => mockBleRepository.stopAdvertising()).called(2);
        },
      );
    });

    group('DiscoveryProfileFound', () {
      const profile = DiscoveredProfile(
        peripheralUuid: 'uuid-1',
        displayName: 'Alice',
        linkedInSlug: 'alice',
        rssi: -55,
      );

      blocTest<DiscoveryBloc, DiscoveryState>(
        'adds new profile to list',
        build: () => DiscoveryBloc(
          bleRepository: mockBleRepository,
          authRepository: mockAuthRepository,
        ),
        act: (bloc) => bloc.add(const DiscoveryProfileFound(profile)),
        expect: () => [
          const DiscoveryState(profiles: [profile]),
        ],
      );

      blocTest<DiscoveryBloc, DiscoveryState>(
        'updates existing profile by slug',
        build: () => DiscoveryBloc(
          bleRepository: mockBleRepository,
          authRepository: mockAuthRepository,
        ),
        seed: () => const DiscoveryState(profiles: [profile]),
        act: (bloc) {
          const updated = DiscoveredProfile(
            peripheralUuid: 'uuid-2',
            displayName: 'Alice Updated',
            linkedInSlug: 'alice',
            rssi: -40,
          );
          bloc.add(const DiscoveryProfileFound(updated));
        },
        expect: () => [
          const DiscoveryState(
            profiles: [
              DiscoveredProfile(
                peripheralUuid: 'uuid-2',
                displayName: 'Alice Updated',
                linkedInSlug: 'alice',
                rssi: -40,
              ),
            ],
          ),
        ],
      );
    });

    group('DiscoveryCleared', () {
      blocTest<DiscoveryBloc, DiscoveryState>(
        'clears all profiles',
        build: () => DiscoveryBloc(
          bleRepository: mockBleRepository,
          authRepository: mockAuthRepository,
        ),
        seed: () => const DiscoveryState(
          profiles: [
            DiscoveredProfile(
              peripheralUuid: 'uuid-1',
              displayName: 'Alice',
              linkedInSlug: 'alice',
              rssi: -55,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const DiscoveryCleared()),
        expect: () => [
          const DiscoveryState(),
        ],
      );
    });
  });
}
