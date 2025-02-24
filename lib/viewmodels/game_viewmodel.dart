import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

// Add at the top of the class with other properties
typedef GameOverCallback = void Function();

/// GameViewModel manages the game state and timer functionality
class GameViewModel extends ChangeNotifier {
  // Game state properties
  String? _gameMode;     // Current game mode ('Time' or 'Points')
  int? _gameValue;       // Target value (minutes for Time mode, points for Points mode)
  Timer? _timer;         // Timer instance for tracking game time
  int _timeInSeconds = 0; // Current time elapsed/remaining in seconds
  bool _isGameActive = false; // Flag to track if game is running
  bool _isFlashing = false; // Flash state
  Timer? _flashTimer;
  Timer? _vibrationTimer; // Add new property for vibration

  // Add points-related properties
  int _player1Points = 0;
  int _player2Points = 0;
  int? _targetPoints; // Points to win (for Points mode)

  // Add winner property
  String? _winner;

  // Add callback property
  GameOverCallback? _onGameOver;

  // Add player name properties
  String _player1Name = 'Player 1';
  String _player2Name = 'Player 2';

  // Getters for accessing private properties
  String? get gameMode => _gameMode;
  int? get gameValue => _gameValue;
  bool get isGameActive => _isGameActive;

  // Add getters
  int get player1Points => _player1Points;
  int get player2Points => _player2Points;
  int? get targetPoints => _targetPoints;

  // Add winner getter
  String? get winner => _winner;

  // Add getters for player names
  String get player1Name => _player1Name;
  String get player2Name => _player2Name;

  // Add setter for callback
  set onGameOver(GameOverCallback callback) {
    _onGameOver = callback;
  }

  // Add setters for player names
  set player1Name(String name) {
    _player1Name = name;
    notifyListeners();
  }

  set player2Name(String name) {
    _player2Name = name;
    notifyListeners();
  }

  // Add getter for text color
  Color get timerColor {
    if (_gameMode == 'Time' && _gameValue != null) {
      int remainingTime = (_gameValue! * 60) - _timeInSeconds;
      if (remainingTime <= 30) {
        return _isFlashing ? Colors.red : Colors.white;
      }
    }
    return Colors.white;
  }

  /// Returns formatted time string in MM:SS format
  /// For Time mode: shows countdown from selected minutes
  /// For other modes: shows elapsed time
  String get formattedTime {
    if (_gameMode == 'Time' && _gameValue != null) {
      // Calculate remaining time for countdown
      int totalSeconds = _gameValue! * 60;    // Convert minutes to seconds
      int remainingTime = totalSeconds - _timeInSeconds;
      
      // Simply return 00:00 if time is up, let the timer handle stopping
      if (remainingTime <= 0) {
        return '00:00';
      }

      // Convert remaining seconds to minutes and seconds
      int minutes = remainingTime ~/ 60;
      int seconds = remainingTime % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // Format elapsed time for non-time modes
      int minutes = _timeInSeconds ~/ 60;
      int seconds = _timeInSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Starts the game timer and initializes game state
  void startGame() {
    _isGameActive = true;
    _timeInSeconds = 0;
    _timer?.cancel();  // Cancel any existing timer
    _flashTimer?.cancel();

    // Start a new timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameMode == 'Time' && _gameValue != null) {
        // Check if time is up before incrementing
        if (_timeInSeconds >= _gameValue! * 60) {
          _determineWinnerForTimeMode();
          stopGame();
          return;
        }
        
        _timeInSeconds++;
        // Calculate remaining time after increment
        int remainingTime = (_gameValue! * 60) - _timeInSeconds;
        
        // Start flashing at 30 seconds remaining
        if (remainingTime == 30) {
          _startFlashing();
        }

        // Start vibration at 10 seconds remaining
        if (remainingTime == 10) {
          _startVibrating();
        }
        
        notifyListeners();
      } else {
        // Other modes: Simply increment time
        _timeInSeconds++;
        notifyListeners();
      }
    });
  }

  void _startFlashing() {
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _isFlashing = !_isFlashing;
      notifyListeners();
    });
  }

  /// Handles vibration for last 10 seconds
  void _startVibrating() async {
    // First check if device has vibration capability
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) {
      try {
        // Create pattern for 10 seconds: vibrate for 500ms, pause for 500ms
        List<int> pattern = List.filled(20, 500); // 10 seconds * 2 (vibrate + pause)
        Vibration.vibrate(pattern: pattern);
        
        print("Vibration started"); // Debug print
      } catch (e) {
        print("Vibration error: $e"); // Debug print
      }
    } else {
      print("No vibrator available"); // Debug print
    }
  }

  /// Stops the game and cancels the timer
  void stopGame() {
    _isGameActive = false;
    _timer?.cancel();
    _flashTimer?.cancel();
    _vibrationTimer?.cancel();
    _isFlashing = false;
    Vibration.cancel();
    
    // Call callback when game is over and we have a winner
    if (_winner != null && _onGameOver != null) {
      _onGameOver!();
    }
    notifyListeners();
  }

  /// Sets up game configuration
  /// @param mode: Game mode ('Time' or 'Points')
  /// @param value: Target value (minutes for Time mode, points for Points mode)
  void setGameSettings(String mode, int value) {
    _gameMode = mode;
    if (mode == 'Points') {
      _targetPoints = value;
    } else {
      _gameValue = value;
    }
    resetPoints();
    notifyListeners();
  }

  // Add point management methods
  void addPointToPlayer1() {
    _player1Points++;
    _checkWinCondition();
    notifyListeners();
  }

  void addPointToPlayer2() {
    _player2Points++;
    _checkWinCondition();
    notifyListeners();
  }

  void resetPoints() {
    _player1Points = 0;
    _player2Points = 0;
    notifyListeners();
  }

  void _checkWinCondition() {
    if (_gameMode == 'Points' && _targetPoints != null) {
      if (_player1Points >= _targetPoints!) {
        _winner = _player1Name;
        stopGame();
      } else if (_player2Points >= _targetPoints!) {
        _winner = _player2Name;
        stopGame();
      }
    } else if (_gameMode == 'Time' && _timeInSeconds >= _gameValue! * 60) {
      _determineWinnerForTimeMode();
      stopGame();
    }
  }

  void _determineWinnerForTimeMode() {
    if (_player1Points > _player2Points) {
      _winner = _player1Name;
    } else if (_player2Points > _player1Points) {
      _winner = _player2Name;
    } else {
      _winner = 'Draw';
    }
  }

  /// Resets all game settings to initial state
  void clearGameSettings() {
    _gameMode = null;
    _gameValue = null;
    _timeInSeconds = 0;
    _timer?.cancel();
    _isGameActive = false;
    _flashTimer?.cancel();
    _vibrationTimer?.cancel();
    _isFlashing = false;
    Vibration.cancel();
    _winner = null;
    _player1Name = 'Player 1';
    _player2Name = 'Player 2';
    notifyListeners();
  }

  // Add method to set player names
  void setPlayerNames(String player1, String player2) {
    _player1Name = player1;
    _player2Name = player2;
    notifyListeners();
  }

  /// Cleanup resources when the ViewModel is disposed
  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    _vibrationTimer?.cancel();
    Vibration.cancel();
    super.dispose();
  }
}
