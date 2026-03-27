import 'package:flutter/material.dart';
import 'package:linked_here/app.dart';
import 'package:linked_here/features/auth/data/auth_repository.dart';
import 'package:linked_here/features/discovery/data/ble_repository.dart';

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
