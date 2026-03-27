part of 'discovery_bloc.dart';

/// Base class for all discovery events.
sealed class DiscoveryEvent extends Equatable {
  /// Creates a [DiscoveryEvent].
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Start scanning and advertising.
final class DiscoveryStarted extends DiscoveryEvent {
  /// Creates a [DiscoveryStarted] event.
  const DiscoveryStarted();
}

/// Stop scanning and advertising.
final class DiscoveryStopped extends DiscoveryEvent {
  /// Creates a [DiscoveryStopped] event.
  const DiscoveryStopped();
}

/// A new profile was discovered via BLE.
final class DiscoveryProfileFound extends DiscoveryEvent {
  /// Creates a [DiscoveryProfileFound] event.
  const DiscoveryProfileFound(this.profile);

  /// The discovered profile from BLE.
  final DiscoveredProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// Clear all discovered profiles.
final class DiscoveryCleared extends DiscoveryEvent {
  /// Creates a [DiscoveryCleared] event.
  const DiscoveryCleared();
}
