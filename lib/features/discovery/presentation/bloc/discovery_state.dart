part of 'discovery_bloc.dart';

/// Possible BLE discovery statuses.
enum DiscoveryStatus {
  /// Not scanning or advertising.
  idle,

  /// Actively scanning for nearby profiles.
  scanning,

  /// A BLE error occurred.
  error,
}

/// Immutable state emitted by [DiscoveryBloc].
final class DiscoveryState extends Equatable {
  /// Creates a [DiscoveryState].
  const DiscoveryState({
    this.status = DiscoveryStatus.idle,
    this.profiles = const [],
    this.errorMessage,
  });

  /// The current discovery status.
  final DiscoveryStatus status;

  /// List of nearby profiles discovered via BLE.
  final List<DiscoveredProfile> profiles;

  /// A human-readable error message, if [status] is [DiscoveryStatus.error].
  final String? errorMessage;

  /// Returns a copy of this [DiscoveryState] with the given fields replaced.
  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<DiscoveredProfile>? profiles,
    String? errorMessage,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profiles, errorMessage];
}
