import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

/// Custom typedef for game over callback to improve code readability and type safety
typedef GameOverCallback = void Function();

/// GameViewModel manages the game state and timer functionality
/// Implements ChangeNotifier for reactive UI updates using the Observer pattern
class GameViewModel extends ChangeNotifier {
  // Private fields use underscore prefix for proper encapsulation
  // Nullable types (?) indicate optional values that may not be set immediately
  String? _gameMode;     // Tracks game mode with null safety
  int? _gameValue;       // Flexible value storage for different game modes
  Timer? _timer;         // Cancellable timer for game duration
  int _timeInSeconds = 0;// Tracks elapsed/remaining time
  bool _isGameActive = false; // Game state flag for UI updates
  bool _isFlashing = false;   // Visual feedback state
  Timer? _flashTimer;         // Separate timer for flash animation
  Timer? _vibrationTimer;     // Dedicated timer for haptic feedback

  // Points tracking system with initial values
  int _player1Points = 0;     // Score counter for player 1
  int _player2Points = 0;     // Score counter for player 2
  int? _targetPoints;         // Win condition for points mode

  // Game outcome tracking
  String? _winner;            // Stores winner name, null if game ongoing

  // Callback for game end events
  GameOverCallback? _onGameOver;  // Allows external response to game completion

  // Player identification
  String _player1Name = 'Player 1';  // Default names with meaningful values
  String _player2Name = 'Player 2';

  // Add elapsed time tracking
  int _elapsedSeconds = 0;

  // Public getters provide controlled access to private state
  // Maintaining encapsulation while allowing read access
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

  // Add getter
  int get elapsedSeconds => _elapsedSeconds;

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

  /// Dynamic timer color based on game state
  /// Returns red during final countdown, white otherwise
  Color get timerColor {
    if (_gameMode == 'Time' && _gameValue != null) {
      int remainingTime = (_gameValue! * 60) - _timeInSeconds;
      if (remainingTime <= 30) {
        return _isFlashing ? Colors.red : Colors.white;
      }
    }
    return Colors.white;
  }

  /// Formats time display in MM:SS format
  /// Handles both countdown and count-up scenarios
  String get formattedTime {
    int minutes = _elapsedSeconds ~/ 60;
    int seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Initializes and starts the game session
  /// Sets up timers, resets state, and manages game flow
  void startGame() {
    _isGameActive = true;
    _timeInSeconds = 0;
    _elapsedSeconds = 0;
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
        // Points mode: track elapsed time
        _elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  /// Manages visual feedback for last 30 seconds
  /// Uses alternating boolean state for flash effect
  void _startFlashing() {
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _isFlashing = !_isFlashing;
      notifyListeners();
    });
  }

  /// Implements haptic feedback for final countdown
  /// Includes device capability check and error handling
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

  /// Gracefully terminates game session
  /// Cleans up resources and triggers callbacks
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

  /// Configures game parameters
  /// @param mode Determines game type
  /// @param value Sets win condition
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

  /// Score management methods
  /// Increment points and check win conditions
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

  /// Resets score counters to initial state
  void resetPoints() {
    _player1Points = 0;
    _player2Points = 0;
    notifyListeners();
  }

  /// Evaluates if win conditions are met
  /// Handles both time and points based modes
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

  /// Determines winner in time mode
  /// Considers point totals and handles ties
  void _determineWinnerForTimeMode() {
    if (_player1Points > _player2Points) {
      _winner = _player1Name;
    } else if (_player2Points > _player1Points) {
      _winner = _player2Name;
    } else {
      _winner = 'Draw';
    }
  }

  /// Complete game state reset
  /// Returns all values to initial state
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

  /// Updates player identifiers
  /// Maintains consistency in display names
  void setPlayerNames(String player1, String player2) {
    _player1Name = player1;
    _player2Name = player2;
    notifyListeners();
  }

  /// Resource cleanup
  /// Ensures proper disposal of timers and vibration
  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    _vibrationTimer?.cancel();
    Vibration.cancel();
    super.dispose();
  }
}
