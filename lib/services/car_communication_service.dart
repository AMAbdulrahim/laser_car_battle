import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';
import 'package:laser_car_battle/services/game_commands.dart';

class CarCommunicationService {
  final BluetoothService _bluetoothService;
  final GameCommands _gameCommands;
  
  CarCommunicationService(this._bluetoothService) 
      : _gameCommands = GameCommands(_bluetoothService);

  void setupMessageHandler(Function(Map<String, dynamic>) handler) {
    _gameCommands.handleIncomingMessages(handler);
  }

  Future<void> connectCar(BluetoothDevice device) async {
    try {
      await _bluetoothService.setupMessageHandling(device.id);
      return;
    } catch (e) {
      print('Failed to connect car: $e');
      rethrow;
    }
  }

  Future<void> disconnectCar() async {
    try {
      await _bluetoothService.dispose();
    } catch (e) {
      print('Failed to disconnect car: $e');
      rethrow;
    }
  }

  void sendJoystickControl(String carId, double x, double y) {
    _gameCommands.sendJoystickControl(carId, x, y);
  }

  void sendBrake(String carId, bool isPressed) {
    _gameCommands.sendBrake(carId, isPressed);
  }

  void sendFire(String carId, bool isPressed) {
    _gameCommands.sendFire(carId, isPressed);
  }

  void sendGameStart(String carId, {
    required String gameMode, 
    required int gameValue,
    required String playerName,
  }) {
    _gameCommands.sendGameStart(
      carId,
      gameMode: gameMode,
      gameValue: gameValue,
      playerName: playerName,
    );
  }
}