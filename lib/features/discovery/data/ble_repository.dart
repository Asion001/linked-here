import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:linked_here/core/constants/app_constants.dart';

/// A discovered LinkedIn profile from a nearby BLE peripheral.
class DiscoveredProfile {
  /// Creates a [DiscoveredProfile].
  const DiscoveredProfile({
    required this.peripheralUuid,
    required this.displayName,
    required this.linkedInSlug,
    required this.rssi,
  });

  /// The unique identifier of the BLE peripheral.
  final String peripheralUuid;

  /// The display name from the BLE advertisement / GATT read.
  final String displayName;

  /// The LinkedIn slug from the GATT characteristic.
  final String linkedInSlug;

  /// The signal strength when discovered.
  final int rssi;
}

/// Repository handling BLE scanning (Central) and advertising
/// (Peripheral) for LinkedIn profile discovery.
class BleRepository {
  /// Creates a [BleRepository].
  ///
  /// Accept manager instances for testability.
  BleRepository({
    CentralManager? centralManager,
    PeripheralManager? peripheralManager,
  }) : _centralManager = centralManager ?? CentralManager(),
       _peripheralManager = peripheralManager ?? PeripheralManager();

  final CentralManager _centralManager;
  final PeripheralManager _peripheralManager;

  final _discoveredController = StreamController<DiscoveredProfile>.broadcast();
  StreamSubscription<DiscoveredEventArgs>? _discoverySubscription;
  bool _isScanning = false;
  bool _isAdvertising = false;

  /// Stream of discovered profiles from BLE scanning.
  Stream<DiscoveredProfile> get discoveredProfiles =>
      _discoveredController.stream;

  /// Whether the scanner is currently active.
  bool get isScanning => _isScanning;

  /// Whether advertising is currently active.
  bool get isAdvertising => _isAdvertising;

  /// Current Bluetooth state from the central manager.
  BluetoothLowEnergyState get bluetoothState => _centralManager.state;

  /// Stream of Bluetooth state changes.
  Stream<BluetoothLowEnergyStateChangedEventArgs> get bluetoothStateChanged =>
      _centralManager.stateChanged;

  // ───────────────────── Central (Scanner) ─────────────────────

  /// Starts scanning for nearby LinkedHere peripherals.
  ///
  /// Discovered peripherals are connected to read their GATT
  /// characteristics, then emitted on [discoveredProfiles].
  Future<void> startScanning() async {
    if (_isScanning) return;
    _isScanning = true;

    _discoverySubscription = _centralManager.discovered.listen(
      _onPeripheralDiscovered,
    );

    await _centralManager.startDiscovery(
      serviceUUIDs: [BleConfig.serviceUuid],
    );
  }

  /// Stops the BLE scanner.
  Future<void> stopScanning() async {
    if (!_isScanning) return;
    _isScanning = false;

    await _centralManager.stopDiscovery();
    await _discoverySubscription?.cancel();
    _discoverySubscription = null;
  }

  Future<void> _onPeripheralDiscovered(
    DiscoveredEventArgs eventArgs,
  ) async {
    final peripheral = eventArgs.peripheral;
    final rssi = eventArgs.rssi;

    try {
      // Connect to read GATT characteristics
      await _centralManager.connect(peripheral);

      final services = await _centralManager.discoverGATT(peripheral);
      final service = services
          .where((s) => s.uuid == BleConfig.serviceUuid)
          .firstOrNull;

      if (service == null) {
        await _centralManager.disconnect(peripheral);
        return;
      }

      String? slug;
      String? name;

      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == BleConfig.slugCharacteristicUuid) {
          final value = await _centralManager.readCharacteristic(
            peripheral,
            characteristic,
          );
          slug = utf8.decode(value);
        } else if (characteristic.uuid == BleConfig.nameCharacteristicUuid) {
          final value = await _centralManager.readCharacteristic(
            peripheral,
            characteristic,
          );
          name = utf8.decode(value);
        }
      }

      await _centralManager.disconnect(peripheral);

      if (slug != null && slug.isNotEmpty) {
        _discoveredController.add(
          DiscoveredProfile(
            peripheralUuid: peripheral.uuid.toString(),
            displayName: name ?? slug,
            linkedInSlug: slug,
            rssi: rssi,
          ),
        );
      }
    } on Exception catch (_) {
      // Silently handle connection failures — the peripheral may
      // have moved out of range.
      try {
        await _centralManager.disconnect(peripheral);
      } on Exception catch (_) {
        // Already disconnected.
      }
    }
  }

  // ───────────────────── Peripheral (Advertiser) ─────────────────────

  /// Starts advertising this device's LinkedIn profile via BLE.
  Future<void> startAdvertising({
    required String slug,
    required String displayName,
  }) async {
    if (_isAdvertising) return;

    await _peripheralManager.removeAllServices();

    final service = GATTService(
      uuid: BleConfig.serviceUuid,
      isPrimary: true,
      includedServices: [],
      characteristics: [
        GATTCharacteristic.immutable(
          uuid: BleConfig.slugCharacteristicUuid,
          value: Uint8List.fromList(utf8.encode(slug)),
          descriptors: [],
        ),
        GATTCharacteristic.immutable(
          uuid: BleConfig.nameCharacteristicUuid,
          value: Uint8List.fromList(utf8.encode(displayName)),
          descriptors: [],
        ),
      ],
    );

    await _peripheralManager.addService(service);

    final advertisement = Advertisement(
      name: 'LinkedHere',
      serviceUUIDs: [BleConfig.serviceUuid],
    );

    await _peripheralManager.startAdvertising(advertisement);
    _isAdvertising = true;
  }

  /// Stops BLE advertising.
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    await _peripheralManager.stopAdvertising();
    await _peripheralManager.removeAllServices();
    _isAdvertising = false;
  }

  /// Releases all resources.
  Future<void> dispose() async {
    await stopScanning();
    await stopAdvertising();
    await _discoveredController.close();
  }
}
