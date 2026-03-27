import 'package:flutter/material.dart';
import 'package:linked_here/app.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';
import 'package:linked_here/features/discovery/data/ble_repository.dart';

/// Entry point for the Linked Here application.
///
/// Initializes the [AuthRepository] and [BleRepository], then launches
/// the [App] widget.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authRepository = AuthRepository();
  final bleRepository = BleRepository();

  runApp(
    App(
      authRepository: authRepository,
      bleRepository: bleRepository,
    ),
  );
}
