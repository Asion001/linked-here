import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';
import 'package:linked_here/features/discovery/data/ble_repository.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// Bloc managing BLE scanning and advertising for nearby LinkedIn
/// profile discovery.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  /// Creates a [DiscoveryBloc].
  DiscoveryBloc({
    required BleRepository bleRepository,
    required AuthRepository authRepository,
  }) : _bleRepository = bleRepository,
       _authRepository = authRepository,
       super(const DiscoveryState()) {
    on<DiscoveryStarted>(_onStarted);
    on<DiscoveryStopped>(_onStopped);
    on<DiscoveryProfileFound>(_onProfileFound);
    on<DiscoveryCleared>(_onCleared);
  }

  final BleRepository _bleRepository;
  final AuthRepository _authRepository;
  StreamSubscription<DiscoveredProfile>? _profileSubscription;

  Future<void> _onStarted(
    DiscoveryStarted event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(state.copyWith(status: DiscoveryStatus.scanning));

    try {
      // Start listening for discovered profiles
      _profileSubscription = _bleRepository.discoveredProfiles.listen(
        (profile) => add(DiscoveryProfileFound(profile)),
      );

      // Start advertising our own profile
      final userProfile = await _authRepository.getStoredProfile();
      if (userProfile?.linkedInSlug != null) {
        await _bleRepository.startAdvertising(
          slug: userProfile!.linkedInSlug!,
          displayName: userProfile.displayName,
        );
      }

      // Start scanning for others
      await _bleRepository.startScanning();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: DiscoveryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStopped(
    DiscoveryStopped event,
    Emitter<DiscoveryState> emit,
  ) async {
    await _profileSubscription?.cancel();
    _profileSubscription = null;
    await _bleRepository.stopScanning();
    await _bleRepository.stopAdvertising();
    emit(state.copyWith(status: DiscoveryStatus.idle));
  }

  void _onProfileFound(
    DiscoveryProfileFound event,
    Emitter<DiscoveryState> emit,
  ) {
    // Update or add the profile (deduplicate by slug)
    final updatedProfiles = List<DiscoveredProfile>.from(state.profiles);
    final existingIndex = updatedProfiles.indexWhere(
      (p) => p.linkedInSlug == event.profile.linkedInSlug,
    );

    if (existingIndex >= 0) {
      updatedProfiles[existingIndex] = event.profile;
    } else {
      updatedProfiles.add(event.profile);
    }

    emit(state.copyWith(profiles: updatedProfiles));
  }

  void _onCleared(
    DiscoveryCleared event,
    Emitter<DiscoveryState> emit,
  ) {
    emit(state.copyWith(profiles: []));
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    await _bleRepository.stopScanning();
    await _bleRepository.stopAdvertising();
    return super.close();
  }
}
