part of 'discovery_bloc.dart';

enum DiscoveryStatus {
  idle,
  scanning,
  error,
}

final class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.status = DiscoveryStatus.idle,
    this.profiles = const [],
    this.errorMessage,
  });

  final DiscoveryStatus status;
  final List<DiscoveredProfile> profiles;
  final String? errorMessage;

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
