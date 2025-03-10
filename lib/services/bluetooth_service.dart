// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/models/car_type.dart';

/// BluetoothService handles all BLE (Bluetooth Low Energy) operations.
/// BLE is different from classic Bluetooth:
/// - Uses less power
/// - Has concepts of Services (like channels) and Characteristics (like properties)
/// - Better for small data transfers
class BluetoothService {
  // Instance of flutter_reactive_ble package to handle BLE operations
  final FlutterReactiveBle _ble;
  
  // UUIDs are unique identifiers for BLE services and characteristics
  // These UUIDs must match exactly with the ones in your ESP32 Arduino code
  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  
  // Device name prefixes help identify our cars during scanning
  // ESP32s will advertise these names so we can find them
  static const String CAR1_PREFIX = "Car1";
  static const String CAR2_PREFIX = "Car2";
  
  // Subscription to handle incoming BLE messages
  // StreamSubscription lets us listen to a stream of data and cleanup when done
  StreamSubscription<List<int>>? _messageSubscription;

  // Controller for broadcasting messages to multiple listeners
  // broadcast() allows multiple widgets to listen to the messages
  final _messageController = StreamController<String>.broadcast();
  
  // Constructor initializes the BLE instance
  BluetoothService(): _ble = FlutterReactiveBle();
  
  // Public stream that widgets can listen to for receiving messages
  Stream<String> get messages => _messageController.stream;

  /// Checks if a discovered device is one of our cars by name prefix
  /// During BLE scanning, devices advertise their names
  bool isValidCarDevice(String deviceName) {
    return deviceName.startsWith(CAR1_PREFIX) || 
           deviceName.startsWith(CAR2_PREFIX);
  }

  /// Determines which car type a device is based on its name
  /// Returns null if the device isn't one of our cars
  CarType? getCarType(String deviceName) {
    if (deviceName.startsWith(CAR1_PREFIX)) {
      return CarType.car1;
    } else if (deviceName.startsWith(CAR2_PREFIX)) {
      return CarType.car2;
    }
    return null;
  }

  /// Creates a BluetoothDevice object from a discovered BLE device
  /// DiscoveredDevice comes from the flutter_reactive_ble package
  /// Returns null if the device isn't one of our cars
  BluetoothDevice? createCarDevice(DiscoveredDevice discoveredDevice) {
    // First check if it's one of our cars
    if (!isValidCarDevice(discoveredDevice.name)) {
      return null;
    }

    // Get the car type (Car1 or Car2)
    final carType = getCarType(discoveredDevice.name);
    if (carType == null) {
      return null;
    }

    // Create our custom BluetoothDevice object
    return BluetoothDevice(
      id: discoveredDevice.id,
      name: discoveredDevice.name,
      rssi: discoveredDevice.rssi,  // Signal strength indicator
      carType: carType
    );
  }

  /// Sets up message handling for a connected device
  /// This creates a subscription to receive notifications from the ESP32
  Future<void> setupMessageHandling(String deviceId) async {
    try {
      // Create a characteristic object that identifies:
      // - Which service to use (SERVICE_UUID)
      // - Which characteristic to use (CHARACTERISTIC_UUID)
      // - Which device to communicate with (deviceId)
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(SERVICE_UUID),
        characteristicId: Uuid.parse(CHARACTERISTIC_UUID),
        deviceId: deviceId,
      );

      // Subscribe to notifications from the ESP32
      // When the ESP32 calls characteristic->notify(), we'll receive the data here
      _messageSubscription = _ble.subscribeToCharacteristic(characteristic).listen(
        // When data is received:
        (data) {
          // Convert the received bytes to a string
          final message = utf8.decode(data);
          print('Received from Arduino: $message');
          // Broadcast the message to all listeners
          _messageController.add(message);
        },
        // Handle any errors that occur during communication
        onError: (error) => print('Message error: $error'),
      );
    } catch (e) {
      print('Setup message handling error: $e');
    }
  }

  /// Sends a message to a specific device
  Future<void> sendMessage(String deviceId, String message) async {
    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse(SERVICE_UUID),
        characteristicId: Uuid.parse(CHARACTERISTIC_UUID),
        deviceId: deviceId,
      );

      final data = utf8.encode(message);
      await _ble.writeCharacteristicWithResponse(characteristic, value: data);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  /// Cleanup method to release resources
  /// Always call this when you're done with BLE communications
  Future<void> dispose() async {
    // Cancel the subscription to stop receiving messages
    await _messageSubscription?.cancel();
    // Close the message controller to free resources
    await _messageController.close();
  }
}