import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as serial;
import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/models/car_type.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages Classic Bluetooth functionality including device scanning,
/// connection management, and state tracking.
class BluetoothViewModel extends ChangeNotifier {
  // Instance of flutter_bluetooth_serial package to handle Classic Bluetooth operations
  final serial.FlutterBluetoothSerial _bluetooth = serial.FlutterBluetoothSerial.instance;
  final BluetoothService _bluetoothService = BluetoothService();
  
  // List to store discovered Bluetooth devices
  final List<BluetoothDevice> _devices = [];
  
  // Timers and stream subscriptions for managing async operations
  Timer? _scanTimer;                    // Controls auto-stop of scanning
  StreamSubscription? _scanSubscription;       // Handles device discovery stream
  StreamSubscription? _connectionSubscription; // Handles device connection state stream
  
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

  /// Starts scanning for Classic Bluetooth devices
  /// Automatically stops after 15 seconds
  Future<void> startScan() async {
    if (_isScanning) return;
    
    // Check permissions before starting scan
    bool permissionsGranted = await _ensurePermissions();
    if (!permissionsGranted) {
      print('Required permissions not granted');
      return;
    }
    
    _isScanning = true;
    _devices.clear();
    notifyListeners();
    
    try {
      // Check if Bluetooth is enabled
      bool isEnabled = await _bluetooth.isEnabled ?? false;
      if (!isEnabled) {
        bool? enabled = await _bluetooth.requestEnable();
        if (enabled != true) {
          _isScanning = false;
          notifyListeners();
          return;
        }
      }
      
      // Start scanning for Bluetooth devices
      _scanSubscription = _bluetooth.startDiscovery().listen(
        // Handle discovered device
        (serial.BluetoothDiscoveryResult result) {
          final device = result.device;
          if (device.name != null && device.name!.isNotEmpty) {
            // Show all devices instead of filtering by car type
            final btDevice = BluetoothDevice(
              id: device.address,
              name: device.name!,
              rssi: result.rssi,
              // Assign a default car type for display purposes
              carType: _bluetoothService.getCarType(device.name!) ?? CarType.car1
            );
            
            final index = _devices.indexWhere((d) => d.id == device.address);
            if (index >= 0) {
              _devices[index] = btDevice;
            } else {
              _devices.add(btDevice);
            }
            notifyListeners();
          }
        },
        onDone: () {
          _isScanning = false;
          notifyListeners();
        },
        onError: (e) {
          print('Scan error: $e');
          _isScanning = false;
          notifyListeners();
        },
      );
      
      // Auto-stop scan after 15 seconds to preserve battery
      _scanTimer = Timer(const Duration(seconds: 15), stopScan);
      
    } catch (e) {
      print('Start scan error: $e');
      _isScanning = false;
      notifyListeners();
    }
  }
  
  /// Stops the current scanning operation
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    await _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }
  
  /// Attempts to connect to a specific Bluetooth device
  /// Returns true if connection attempt started successfully
  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return false;
    
    _isConnecting = true;
    notifyListeners();
    
    try {
      // Start connection process using the BluetoothService
      bool connected = await _bluetoothService.connectToDevice(device.id);
      
      if (connected) {
        // Successfully connected
        _connectedDevice = device;
        _connectedDevice!.isConnected = true;
        _bluetoothService.setupMessageHandling(device.id);
        
        // Subscribe to connection state change events
        _connectionSubscription = _bluetooth.onStateChanged().listen((state) {
          if (state == serial.BluetoothState.STATE_OFF || 
              state == serial.BluetoothState.STATE_TURNING_OFF) {
            _connectedDevice?.isConnected = false;
            _connectedDevice = null;
            notifyListeners();
          }
        });
      }
      
      _isConnecting = false;
      notifyListeners();
      return connected;
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
    await _bluetoothService.disconnect();
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

  // Check and request permissions needed for Bluetooth
  Future<bool> _ensurePermissions() async {
    // For Android 12+ we need to request BLUETOOTH_SCAN and BLUETOOTH_CONNECT
    if (await Permission.bluetoothScan.status.isDenied) {
      await Permission.bluetoothScan.request();
    }
    
    if (await Permission.bluetoothConnect.status.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    
    // Location permission is often required for Bluetooth scanning
    if (await Permission.location.status.isDenied) {
      await Permission.location.request();
    }
    
    // Check if permissions were granted
    final locationStatus = await Permission.location.status;
    final scanStatus = await Permission.bluetoothScan.status;
    final connectStatus = await Permission.bluetoothConnect.status;
    
    return locationStatus.isGranted && 
           (scanStatus.isGranted || scanStatus.isLimited) &&
           (connectStatus.isGranted || connectStatus.isLimited);
  }
}