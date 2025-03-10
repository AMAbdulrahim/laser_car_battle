import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';

/// Manages Bluetooth Low Energy (BLE) functionality including device scanning,
/// connection management, and state tracking.
class BluetoothViewModel extends ChangeNotifier {
  // Instance of flutter_reactive_ble package to handle BLE operations
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final BluetoothService _bluetoothService = BluetoothService();
  
  // List to store discovered BLE devices
  final List<BluetoothDevice> _devices = [];
  
  // Timers and stream subscriptions for managing async operations
  Timer? _scanTimer;                    // Controls auto-stop of scanning
  StreamSubscription? _scanSubscription;       // Handles device discovery stream
  StreamSubscription? _connectionSubscription; // Handles device connection stream
  
  // Internal state tracking
  bool _isScanning = false;    // Indicates if currently scanning for devices
  bool _isConnecting = false;  // Indicates if currently connecting to a device
  BluetoothDevice? _connectedDevice;  // Currently connected device, if any
  
  // Public getters to access state
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  List<BluetoothDevice> get devices => List.unmodifiable(_devices);  // Returns immutable list of discovered devices
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  // Expose the message stream from the service
  Stream<String> get messages => _bluetoothService.messages;

  /// Starts scanning for BLE devices
  /// Automatically stops after 10 seconds
  Future<void> startScan() async {
    // Prevent multiple concurrent scans
    if (_isScanning) return;
    
    _isScanning = true;
    _devices.clear();  // Clear previous scan results
    notifyListeners();
    
    try {
      // Start scanning for BLE devices
      _scanSubscription = _ble.scanForDevices(
        withServices: [],  // Empty list means scan for all services
        scanMode: ScanMode.lowLatency,  // Optimized for quick discovery
      ).listen(
        // Handle discovered device
        (device) {
          if (device.name.isNotEmpty) {
            // Get car type from bluetooth service
            final carType = _bluetoothService.getCarType(device.name);
            
            // Only process if it's a valid car device
            if (carType != null) {
              final btDevice = BluetoothDevice(
                id: device.id,
                name: device.name,
                rssi: device.rssi,
                carType: carType  // Add the car type here
              );
              
              final index = _devices.indexWhere((d) => d.id == device.id);
              if (index >= 0) {
                _devices[index] = btDevice;
              } else {
                _devices.add(btDevice);
              }
              notifyListeners();
            }
          }
        },
        onError: (e) => print('Scan error: $e'),
      );
      
      // Auto-stop scan after 15 seconds to preserve battery
      _scanTimer = Timer(const Duration(seconds: 15), stopScan);
      
    } catch (e) {
      print('Start scan error: $e');
      stopScan();
    }
  }
  
  /// Stops the current scanning operation
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    await _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }
  
  /// Attempts to connect to a specific BLE device
  /// Returns true if connection attempt started successfully
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return false;
    
    _isConnecting = true;
    notifyListeners();
    
    try {
      // Start connection process
      _connectionSubscription = _ble.connectToDevice(
        id: device.id,
        connectionTimeout: const Duration(seconds: 10),
      ).listen(
        // Handle connection state changes
        (state) {
          if (state.connectionState == DeviceConnectionState.connected) {
            // Successfully connected
            _connectedDevice = device;
            _connectedDevice!.isConnected = true;
            _bluetoothService.setupMessageHandling(device.id);
          } else if (state.connectionState == DeviceConnectionState.disconnected) {
            // Handle disconnection
            _connectedDevice?.isConnected = false;
            _connectedDevice = null;
          }
          
          _isConnecting = state.connectionState == DeviceConnectionState.connecting;
          notifyListeners();
        },
        onError: (e) {
          print('Connection error: $e');
          _isConnecting = false;
          notifyListeners();
        },
      );
      
      return true;
    } catch (e) {
      print('Connect error: $e');
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Disconnects from the currently connected device
  Future<void> disconnectDevice() async {
    await _connectionSubscription?.cancel();
    _connectedDevice?.isConnected = false;
    _connectedDevice = null;
    notifyListeners();
  }

  /// Cleanup resources when the ViewModel is disposed
  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _bluetoothService.dispose();
    super.dispose();
  }
}