part of 'discovery_bloc.dart';

sealed class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Start scanning and advertising.
final class DiscoveryStarted extends DiscoveryEvent {
  const DiscoveryStarted();
}

/// Stop scanning and advertising.
final class DiscoveryStopped extends DiscoveryEvent {
  const DiscoveryStopped();
}

/// A new profile was discovered via BLE.
final class DiscoveryProfileFound extends DiscoveryEvent {
  const DiscoveryProfileFound(this.profile);

  final DiscoveredProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Clear all discovered profiles.
final class DiscoveryCleared extends DiscoveryEvent {
  const DiscoveryCleared();
}
