import 'package:flutter/foundation.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:vibration/vibration.dart';

class CarControllerViewModel extends ChangeNotifier {
  final GameViewModel gameViewModel;

  CarControllerViewModel({required this.gameViewModel});

  // Joystick controls
  double _xAxis = 0.0;
  double _yAxis = 0.0;
  
  // Button states
  bool _isBraking = false;

  // Getters
  double get xAxis => _xAxis;
  double get yAxis => _yAxis;
  bool get isBraking => _isBraking;

  // Methods to update control states
  void updateJoystickPosition(double x, double y) {
    _xAxis = double.parse(x.toStringAsFixed(2));
    _yAxis = double.parse(y.toStringAsFixed(2));
    notifyListeners();
    // TODO: Send to Arduino
    print('Joystick Update: $_xAxis, $_yAxis');
  }

  void setBrakeState(bool braking) {
    _isBraking = braking;
    notifyListeners();
    // TODO: Send to Arduino
    print('Brake State: $_isBraking');
  }

  // Modify fire method to handle hits
  void fire() async {
    if (await Vibration.hasVibrator() ) {
      Vibration.vibrate(duration: 100, amplitude: 255);
    }

    // TODO: Send fire signal to Arduino
    print('Fire!');
    gameViewModel.addPointToPlayer1(); // (!!!) Temporary: add point to player 1 

    // TODO: When hit is detected from Arduino
    // handleHit(playerNumber);
  }

  // Add method to handle hits
  void handleHit(int playerHit) {
    if (!gameViewModel.isGameActive) return;

    if (playerHit == 1) {
      gameViewModel.addPointToPlayer2();
    } else if (playerHit == 2) {
      gameViewModel.addPointToPlayer1();
    }
  }

  // Method to get all control states
  Map<String, dynamic> getAllControlStates() {
    return {
      'joystick': {
        'x': _xAxis,
        'y': _yAxis,
      },
      'brake': _isBraking,
      'lastFired': DateTime.now().toString(), // Optional: add timestamp for fire events
    };
  }

  // Helper method to print all states
  void debugPrintAllStates() {
    final states = getAllControlStates();
    print('Current Control States:');
    print('Joystick: (${states['joystick']['x']}, ${states['joystick']['y']})');
    print('Brake: ${states['brake']}');
  }
}