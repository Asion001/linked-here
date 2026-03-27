import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_here/core/utils/linkedin_utils.dart';
import 'package:linked_here/core/widgets/profile_card.dart';
import 'package:linked_here/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Main screen for discovering nearby LinkedIn profiles.
class DiscoveryScreen extends StatelessWidget {
  /// Creates a [DiscoveryScreen].
  const DiscoveryScreen({super.key});

  Future<void> _openLinkedInProfile(
    BuildContext context,
    String slug,
  ) async {
    final url = Uri.parse(buildLinkedInUrl(slug));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open LinkedIn profile'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoveryBloc, DiscoveryState>(
      listenWhen: (previous, current) =>
          current.status == DiscoveryStatus.error,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isScanning = state.status == DiscoveryStatus.scanning;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Linked Here'),
            actions: [
              if (isScanning)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
          body: state.profiles.isEmpty
              ? _EmptyState(isScanning: isScanning)
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: state.profiles.length,
                  itemBuilder: (context, index) {
                    final profile = state.profiles[index];
                    return ProfileCard(
                      displayName: profile.displayName,
                      linkedInSlug: profile.linkedInSlug,
                      rssi: profile.rssi,
                      onTap: () => _openLinkedInProfile(
                        context,
                        profile.linkedInSlug,
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (isScanning) {
                context.read<DiscoveryBloc>().add(const DiscoveryStopped());
              } else {
                context.read<DiscoveryBloc>().add(const DiscoveryStarted());
              }
            },
            icon: Icon(
              isScanning ? Icons.stop : Icons.bluetooth_searching,
            ),
            label: Text(isScanning ? 'Stop' : 'Scan'),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isScanning});

  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isScanning ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              isScanning
                  ? 'Searching for nearby profiles...'
                  : 'Tap Scan to discover nearby\nLinkedIn profiles',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
