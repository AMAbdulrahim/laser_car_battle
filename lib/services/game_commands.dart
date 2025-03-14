import 'dart:convert';
import 'package:laser_car_battle/services/bluetooth_service.dart';

/// Handles all game-specific BLE commands between app and cars
class GameCommands {
  final BluetoothService _bluetoothService;
  
  // Command types
  static const String CMD_CONTROL = "control";
  static const String CMD_FIRE = "fire";
  static const String CMD_BRAKE = "brake";
  static const String CMD_GAME_START = "gameStart";
  static const String CMD_GAME_END = "gameEnd";
  static const String CMD_HIT = "hit";

  GameCommands(this._bluetoothService);

  /// Sends joystick control values to car
  Future<void> sendJoystickControl(String deviceId, double x, double y) async {
    final message = {
      "cmd": CMD_CONTROL,
      "x": x.clamp(-1.0, 1.0), // Normalize between -1 and 1
      "y": y.clamp(-1.0, 1.0),
    };
    // await _sendMessage(deviceId, message);
    print('DEBUG - Joystick Control: $message');
  }

  /// Sends fire command to car
  Future<void> sendFire(String deviceId, bool isPressed) async {
    final message = {
      "cmd": CMD_FIRE,
      "active": isPressed,
    };
    // await _sendMessage(deviceId, message);
    print('DEBUG - Fire Command: $message');
  }

  /// Sends brake command to car
  Future<void> sendBrake(String deviceId, bool isPressed) async {
    final message = {
      "cmd": CMD_BRAKE,
      "active": isPressed,
    };
    // await _sendMessage(deviceId, message);
    print('DEBUG - Brake Command: $message');
  }

  /// Sends game start configuration
  Future<void> sendGameStart(String deviceId, {
    required String gameMode,
    required int gameValue,
    required String playerName,
  }) async {
    final message = {
      "cmd": CMD_GAME_START,
      "mode": gameMode,
      "value": gameValue,
      "player": playerName,
    };
    // await _sendMessage(deviceId, message);
    print('DEBUG - Game Start: $message');
  }

  /// Sends game end signal
  Future<void> sendGameEnd(String deviceId) async {
    final message = {
      "cmd": CMD_GAME_END,
    };
    // await _sendMessage(deviceId, message);
    print('DEBUG - Game End: $message');
  }

  /// Handles incoming messages from cars
  void handleIncomingMessages(Function(Map<String, dynamic>) onHit) {
    _bluetoothService.messages.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data['cmd'] == CMD_HIT) {
          onHit(data);
        }
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
  }

  /// Helper method to send messages to car
  // Future<void> _sendMessage(String deviceId, Map<String, dynamic> message) async {
  //   /* Commented during development
  //   try {
  //     final jsonMessage = jsonEncode(message);
  //     await _bluetoothService.sendMessage(deviceId, jsonMessage);
  //     print('Sent to $deviceId: $jsonMessage');
  //   } catch (e) {
  //     print('Error sending message: $e');
  //   }
  //   */
  //   print('DEBUG - Would send to $deviceId: $message');
  // }
}