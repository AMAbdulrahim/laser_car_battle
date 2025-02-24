import 'package:flutter/foundation.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:vibration/vibration.dart';

/// CarControllerViewModel manages the car's control state and interactions
/// Implements ChangeNotifier for reactive UI updates in the MVVM pattern
class CarControllerViewModel extends ChangeNotifier {
  // Reference to main game state for score management and game status
  // Dependency injection promotes loose coupling and testability
  final GameViewModel gameViewModel;

  /// Constructor enforces required game state dependency
  CarControllerViewModel({required this.gameViewModel});

  // Control state variables using private fields for encapsulation
  // Using double for precise analog control values
  double _xAxis = 0.0;    // Horizontal movement control (-1.0 to 1.0)
  double _yAxis = 0.0;    // Vertical movement control (-1.0 to 1.0)
  
  // Boolean state for digital controls
  bool _isBraking = false;  // Brake state indicator

  /// Public getters provide read-only access to control states
  /// Maintains encapsulation while allowing state observation
  double get xAxis => _xAxis;
  double get yAxis => _yAxis;
  bool get isBraking => _isBraking;

  /// Updates joystick position with precision rounding
  /// @param x Horizontal axis value (-1.0 to 1.0)
  /// @param y Vertical axis value (-1.0 to 1.0)
  void updateJoystickPosition(double x, double y) {
    // Round to 2 decimal places for practical precision and noise reduction
    _xAxis = double.parse(x.toStringAsFixed(2));
    _yAxis = double.parse(y.toStringAsFixed(2));
    notifyListeners();
    // TODO: Implement Arduino communication
    print('Joystick Update: $_xAxis, $_yAxis');
  }

  /// Updates brake state and notifies listeners
  /// @param braking New brake state
  void setBrakeState(bool braking) {
    _isBraking = braking;
    notifyListeners();
    // TODO: Implement Arduino communication
    print('Brake State: $_isBraking');
  }

  /// Handles fire action with haptic feedback
  /// Temporarily adds points for testing (to be replaced with actual hit detection)
  void fire() async {
    // Provide tactile feedback for fire action
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100, amplitude: 255);
    }

    // TODO: Implement Arduino communication for firing
    print('Fire!');
    // Temporary point addition for testing
    gameViewModel.addPointToPlayer1();

    // TODO: Implement actual hit detection from Arduino
    // handleHit(playerNumber);
  }

  /// Processes hit detection and updates game score
  /// @param playerHit The player number that was hit (1 or 2)
  void handleHit(int playerHit) {
    // Prevent score changes when game is not active
    if (!gameViewModel.isGameActive) return;

    // Award point to opposite player when hit is detected
    if (playerHit == 1) {
      gameViewModel.addPointToPlayer2();
    } else if (playerHit == 2) {
      gameViewModel.addPointToPlayer1();
    }
  }

  /// Provides complete control state snapshot
  /// Useful for debugging and state synchronization
  Map<String, dynamic> getAllControlStates() {
    return {
      'joystick': {
        'x': _xAxis,
        'y': _yAxis,
      },
      'brake': _isBraking,
      'lastFired': DateTime.now().toString(),
    };
  }

  /// Debug utility for control state monitoring
  /// Prints current state values to console
  void debugPrintAllStates() {
    final states = getAllControlStates();
    print('Current Control States:');
    print('Joystick: (${states['joystick']['x']}, ${states['joystick']['y']})');
    print('Brake: ${states['brake']}');
  }
}