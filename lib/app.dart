import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_here/core/theme/app_theme.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';
import 'package:linked_here/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:linked_here/features/auth/presentation/screens/login_screen.dart';
import 'package:linked_here/features/discovery/data/ble_repository.dart';
import 'package:linked_here/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:linked_here/features/discovery/presentation/screens/discovery_screen.dart';
import 'package:linked_here/features/settings/presentation/screens/settings_screen.dart';

/// The root widget of the LinkedHere application.
class App extends StatefulWidget {
  /// Creates the [App].
  const App({
    required this.authRepository,
    required this.bleRepository,
    super.key,
  });

  /// The authentication repository instance.
  final AuthRepository authRepository;

  /// The BLE repository instance.
  final BleRepository bleRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.authRepository),
        RepositoryProvider.value(value: widget.bleRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AuthBloc(authRepository: widget.authRepository)
                  ..add(const AuthCheckRequested()),
          ),
          BlocProvider(
            create: (_) => DiscoveryBloc(
              bleRepository: widget.bleRepository,
              authRepository: widget.authRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Linked Here',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const _AppShell(),
        ),
      ),
    );
  }
}

/// Shell widget that switches screens based on auth state.
class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state.status) {
          AuthStatus.initial || AuthStatus.loading => const _SplashScreen(),
          AuthStatus.unauthenticated || AuthStatus.error => const LoginScreen(),
          AuthStatus.authenticated => const _AuthenticatedShell(),
        };
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Bottom navigation shell for authenticated users.
class _AuthenticatedShell extends StatefulWidget {
  const _AuthenticatedShell();

  @override
  State<_AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<_AuthenticatedShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [DiscoveryScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bluetooth_searching),
            selectedIcon: Icon(Icons.bluetooth_connected),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
