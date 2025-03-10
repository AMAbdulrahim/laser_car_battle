import 'package:flutter/foundation.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:vibration/vibration.dart';

/// CarControllerViewModel manages the car's control state and interactions
/// Implements ChangeNotifier for reactive UI updates in the MVVM pattern
class CarControllerViewModel extends ChangeNotifier {
  double _xAxis = 0;
  double _yAxis = 0;
  bool _isBraking = false;
  int _fireCount = 0;
  String _lastAction = 'None';
  final GameViewModel gameViewModel;
  final int playerNumber;  // 1 or 2 to identify which player's controller this is

  CarControllerViewModel({
    required this.gameViewModel,
    required this.playerNumber,
  });

  // Get the car ID dynamically based on connected cars
  String? get carId {
    return playerNumber == 1 ? 
           gameViewModel.car1?.id : 
           gameViewModel.car2?.id;
  }

  // Only allow control if we have a connected car
  bool get isCarConnected => carId != null;

  /// Public getters provide read-only access to control states
  /// Maintains encapsulation while allowing state observation
  double get xAxis => _xAxis;
  double get yAxis => _yAxis;
  bool get isBraking => _isBraking;
  int get fireCount => _fireCount;
  String get lastAction => _lastAction;

  /// Updates joystick position with precision rounding
  /// @param x Horizontal axis value (-1.0 to 1.0)
  /// @param y Vertical axis value (-1.0 to 1.0)
  void updateJoystickPosition(double x, double y) {
    // Comment out connection check during development
    // if (!isCarConnected) return;
    
    // Round to 2 decimal places for practical precision
    _xAxis = x;  // Remove parsing since values are already correct
    _yAxis = y;
    _lastAction = 'Joystick: (${_xAxis.toStringAsFixed(2)}, ${_yAxis.toStringAsFixed(2)})';
    notifyListeners();
    
    // Debug output
    print('DEBUG - Player $playerNumber Joystick: x=$_xAxis, y=$_yAxis');
    
    // Only send to Arduino if connected
    final currentCarId = carId;
    if (currentCarId != null) {
      gameViewModel.sendJoystickControl(currentCarId, _xAxis, _yAxis);
    }
  }

  /// Updates brake state and notifies listeners
  /// @param braking New brake state
  void setBrakeState(bool braking) {
    // Comment out connection check during development
    // if (!isCarConnected) return;
    
    _isBraking = braking;
    _lastAction = braking ? 'Brake Pressed' : 'Brake Released';
    notifyListeners();
    
    // Debug output
    print('DEBUG - Brake: $_isBraking');
    
    // Only send to Arduino if connected
    final currentCarId = carId;
    if (currentCarId != null) {
      gameViewModel.sendBrake(currentCarId, _isBraking);
    }
  }

  /// Handles fire action with haptic feedback
  /// Temporarily adds points for testing (to be replaced with actual hit detection)
  void fire() async {
    // Comment out connection check during development
    // if (!isCarConnected) return;
    
    _fireCount++;
    _lastAction = 'Fire! (${_fireCount})';
    notifyListeners();
    
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100, amplitude: 255);
    }
    
    // Debug output
    print('DEBUG - Fire Button Pressed! Count: $_fireCount');
    
    // Temporarily add points for testing
    gameViewModel.addPointToPlayer1(); // !!! Remove this line after hit detection is implemented

    // Only send to Arduino if connected
    final currentCarId = carId;
    if (currentCarId != null) {
      gameViewModel.sendFire(currentCarId, true);
    }
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

  /// Resets all debug values to initial state
  void resetDebugValues() {
    _xAxis = 0;
    _yAxis = 0;
    _isBraking = false;
    _fireCount = 0;
    _lastAction = 'Game Reset';
    notifyListeners();
    print('DEBUG - Player $playerNumber values reset');
  }
}