// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:laser_car_battle/models/car_type.dart';

/// BluetoothService handles all Classic Bluetooth operations.
/// Classic Bluetooth differs from BLE:
/// - Requires explicit pairing
/// - Uses higher power consumption
/// - Better for continuous data transfer
/// - Uses Socket-based communication instead of GATT
class BluetoothService {
  // Connection related variables
  BluetoothConnection? _connection;
  
  // Device name prefixes help identify our cars during scanning
  static const String CAR1_PREFIX = "Car1";
  static const String CAR2_PREFIX = "Car2";
  
  // Controller for broadcasting messages to multiple listeners
  final _messageController = StreamController<String>.broadcast();
  
  // Public stream that widgets can listen to for receiving messages
  Stream<String> get messages => _messageController.stream;

  // Add this field to BluetoothService
  final StringBuffer _buffer = StringBuffer();

  /// Checks if a discovered device is one of our cars by name prefix
  bool isValidCarDevice(String deviceName) {
    return deviceName.startsWith(CAR1_PREFIX) || 
           deviceName.startsWith(CAR2_PREFIX);
  }

  /// Determines which car type a device is based on its name
  CarType? getCarType(String deviceName) {
    if (deviceName.startsWith(CAR1_PREFIX)) {
      return CarType.car1;
    } else if (deviceName.startsWith(CAR2_PREFIX)) {
      return CarType.car2;
    }
    return null;
  }

  /// Connects to a device using its address
  Future<bool> connectToDevice(String address) async {
    try {
      // Attempt to establish connection
      _connection = await BluetoothConnection.toAddress(address);
      print('Connected to device: $address');
      
      // Start listening for incoming data
      _setupDataListening();
      
      return _connection?.isConnected ?? false;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }

  /// Sets up data listening for a connected device
  void _setupDataListening() {
    _connection?.input?.listen(
      (Uint8List data) {
        // Convert bytes to string and add to buffer
        final textChunk = utf8.decode(data);
        _buffer.write(textChunk);
        
        // Check if we have complete messages (ending with newline)
        String bufferString = _buffer.toString();
        if (bufferString.contains('\n')) {
          // Split by newlines and process each complete message
          List<String> messages = bufferString.split('\n');
          
          // The last element might be incomplete (no trailing newline)
          String lastPart = messages.removeLast();
          
          // Process complete messages
          for (String message in messages) {
            if (message.isNotEmpty) {
              print('Received complete message: $message');
              _messageController.add(message);
            }
          }
          
          // Keep the remaining incomplete part in the buffer
          _buffer.clear();
          _buffer.write(lastPart);
        }
      },
      onDone: () {
        print('Disconnected by remote request');
      },
      onError: (error) {
        print('Data receive error: $error');
      }
    );
  }

  /// Sets up message handling for a connected device (called after connection)
  Future<void> setupMessageHandling(String deviceId) async {
    // In classic Bluetooth, message handling is setup during connection
    // This method is kept for compatibility with existing code
  }

  /// Sends a message to a connected device
  Future<void> sendMessage(String deviceId, String message) async {
    try {
      if (_connection?.isConnected ?? false) {
        // Convert string to Uint8List (bytes)
        Uint8List data = Uint8List.fromList(utf8.encode('$message\n'));
        _connection?.output.add(data);
        await _connection?.output.allSent;
        print('Sent: $message');
      } else {
        print('Not connected, cannot send message');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  /// Disconnects from the currently connected device
  Future<void> disconnect() async {
    try {
      await _connection?.close();
      _connection = null;
      print('Disconnected from device');
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  /// Cleanup method to release resources
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
  }
}