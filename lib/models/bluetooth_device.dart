import 'package:laser_car_battle/models/car_type.dart';

class BluetoothDevice {
  final String id;
  final String name;
  final int rssi;
  final CarType carType;
  bool isConnected;

  BluetoothDevice({
    required this.id,
    required this.name,
    required this.carType,
    this.rssi = 0,
    this.isConnected = false,
  });

  @override
  String toString() {
    return 'BluetoothDevice{name: $name, type: $carType, rssi: $rssi, connected: $isConnected}';
  }
}