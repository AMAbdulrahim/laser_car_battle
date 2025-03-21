import 'package:flutter/material.dart';
import 'package:laser_car_battle/models/bluetooth_device.dart';
import 'package:laser_car_battle/models/car_type.dart';
import 'package:laser_car_battle/models/game_session.dart';
import 'package:laser_car_battle/models/leaderboard_entry.dart';
import 'package:laser_car_battle/services/bluetooth_service.dart';
import 'package:laser_car_battle/services/game_commands.dart';
import 'package:laser_car_battle/services/game_sync_service.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/leaderboard_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'dart:math';

/// Custom typedef for game over callback to improve code readability and type safety
typedef GameOverCallback = void Function();

/// GameViewModel manages the game state and timer functionality
/// Implements ChangeNotifier for reactive UI updates using the Observer pattern
class GameViewModel extends ChangeNotifier {
  final LeaderboardViewModel? _leaderboardViewModel;
  final BluetoothService _bluetoothService;
  final GameCommands _gameCommands;
  final GlobalKey<NavigatorState> navigatorKey;
  late final GameSyncService _gameSyncService;
  
  // Connected cars
  BluetoothDevice? _car1;
  BluetoothDevice? _car2;

  // Private fields use underscore prefix for proper encapsulation
  // Nullable types (?) indicate optional values that may not be set immediately
  String? _gameMode;     // Tracks game mode with null safety
  int? _gameValue;       // Flexible value storage for different game modes
  Timer? _timer;         // Cancellable timer for game duration
  int _timeInSeconds = 0;// Tracks elapsed/remaining time
  bool _isGameActive = false; // Game state flag for UI updates //!
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
  VoidCallback? _onGameOver;  // Allows external response to game completion

  // Player identification
  String _player1Name = 'Player 1';  // Default names with meaningful values
  String _player2Name = 'Player 2';

  // Add elapsed time tracking
  int _elapsedSeconds = 0;

  // Add these near the top of the class with other fields
  bool _isHost = false;
  bool get isHost => _isHost;

  // Add these fields to the GameViewModel class
  String? _gameSessionId;

  // Add these fields near the top of the class
  String? _gameCode;
  String get gameCode => _gameCode ?? '';

  // Add this flag near the top of your GameViewModel class with other boolean properties
  bool _debugBypassActiveCheck = false; // Set to true to bypass isActive check during debugging
  bool get debugBypassActiveCheck => _debugBypassActiveCheck;

  // Add this field near other fields in GameViewModel
  bool _leaderboardUpdated = false;

  // First, add a "frozen" time property that won't change after game ends
  int _finalElapsedSeconds = 0;

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
  set onGameOver(VoidCallback callback) => _onGameOver = callback;

  // Add setters for player names
  set player1Name(String name) {
    _player1Name = name;
    notifyListeners();
  }

  set player2Name(String name) {
    _player2Name = name;
    notifyListeners();
  }

  // Add this method
  void setIsHost(bool value) {
    _isHost = value;
    notifyListeners();
  }

  // Add this method to generate a game code
  String _generateGameCode() {
    const chars = '0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Add a setter to toggle this value
  void setDebugBypassActiveCheck(bool value) {
    _debugBypassActiveCheck = value;
    print("Debug bypass active check set to: $value");
    if (value) {
      printDebugStatus();
    }
    notifyListeners();
  }

  // Update constructor
  GameViewModel(
    this._bluetoothService,
    this.navigatorKey,
    this._leaderboardViewModel,
    SupabaseClient supabaseClient,
  ) : _gameCommands = GameCommands(_bluetoothService) {
    // Initialize GameSyncService after constructor body
    _gameSyncService = GameSyncService(
      supabaseClient,
      onGameUpdate: _handleGameUpdate,
      onHit: _handleHitFromSupabase,
    );

    // Listen for hit events from Bluetooth
    _gameCommands.handleIncomingMessages(_handleHit);
  }

  // Handles hits coming from Supabase
  void _handleHitFromSupabase(bool isPlayer1Hit) {
    _handleHit({'target': isPlayer1Hit ? 'Car1' : 'Car2'});
  }

  // Getters for connected cars
  BluetoothDevice? get car1 => _car1;
  BluetoothDevice? get car2 => _car2;

  // Set connected cars
  void setCar1(BluetoothDevice? device) {
    _car1 = device;
    notifyListeners();
  }

  void setCar2(BluetoothDevice? device) {
    _car2 = device;
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
    if (_gameMode == 'Time') {
      // For Time mode: show remaining time
      int remainingSeconds = (_gameValue! * 60) - _timeInSeconds;
      int minutes = remainingSeconds ~/ 60;
      int seconds = remainingSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // For Points mode: show elapsed time
      int minutes = _elapsedSeconds ~/ 60;
      int seconds = _elapsedSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Add getter for formatted time in Time mode
  String get formattedGameTime {
    if (_gameMode == 'Time') {
      int remainingSeconds = (_gameValue! * 60) - _timeInSeconds;
      int minutes = remainingSeconds ~/ 60;
      int seconds = remainingSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return formattedTime; // Use existing elapsed time formatter for Points mode
  }

  // Add a getter for this value
  int get finalElapsedSeconds => _finalElapsedSeconds;

  // Add a getter for formatted final time that's static
  String get formattedFinalTime {
    int minutes = _finalElapsedSeconds ~/ 60;
    int seconds = _finalElapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Initializes and starts the game session
  /// Sets up timers, resets state, and manages game flow
  Future<String> startGame() async {
    // Immediately set game as active for UI responsiveness
    _isGameActive = true;
    _timeInSeconds = 0;
    _elapsedSeconds = 0;
    _timer?.cancel();
    _flashTimer?.cancel();
    _leaderboardUpdated = false;
    
    // Generate game code immediately (for host)
    if (isHost) {
      _gameCode = _generateGameCode();
    }
    
    // Start game timer immediately for responsive UI
    _startGameTimer();
    
    // Notify listeners early to update UI
    notifyListeners();
    
    // Now handle the network operations in parallel
    if (isHost) {
      // Create session object
      final session = GameSession(
        id: _gameCode!,
        player1Id: _car1?.id ?? 'mock-car1-id',
        player2Id: _car2?.id ?? 'mock-car2-id',
        player1Name: _player1Name,
        player2Name: _player2Name,
        gameMode: _gameMode!,
        gameValue: _gameValue ?? _targetPoints!,
        startTime: DateTime.now(),
      );
      
      // Execute these operations in parallel
      await Future.wait([
        // Create game session in database
        _gameSyncService.createGameSession(session).then((s) {
          _gameSessionId = s.id;
          _gameSyncService.subscribeToGame(_gameSessionId!);
        }).catchError((e) => print('Error creating game session: $e')),
        
        // Send game start to car 1 if connected
        _car1?.id != null 
            ? _gameCommands.sendGameStart(
                _car1!.id,
                gameMode: _gameMode!,
                gameValue: _gameValue ?? _targetPoints!,
                playerName: _player1Name,
              ).catchError((e) => print('Error sending to car 1: $e'))
            : Future.value(),
        
        // Send game start to car 2 if connected
        _car2?.id != null 
            ? _gameCommands.sendGameStart(
                _car2!.id,
                gameMode: _gameMode!,
                gameValue: _gameValue ?? _targetPoints!,
                playerName: _player2Name,
              ).catchError((e) => print('Error sending to car 2: $e'))
            : Future.value(),
      ]);
    } else {
      // For non-hosts, just subscribe to the game
      _gameSessionId = _gameCode;
      _gameSyncService.subscribeToGame(_gameSessionId!);
    }
    
    return _gameCode!;
  }

  // Extract timer setup to a separate method
  void _startGameTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_gameMode == 'Time' && _gameValue != null) {
        _timeInSeconds++;
        
        // Check remaining time
        int remainingTime = (_gameValue! * 60) - _timeInSeconds;
        
        if (remainingTime <= 30 && !_isFlashing) {
          _startFlashing();
        }
        if (remainingTime <= 10 && _vibrationTimer == null) {
          _startVibrating();
        }
        
        if (remainingTime <= 0) {
          _determineWinnerForTimeMode();
          _endGame();
          return;
        }
        
        // Sync time less frequently (every 2 seconds)
        if (_isHost && _timeInSeconds % 2 == 0 && _gameSessionId != null) {
          // Don't await this - let it happen in background
          _gameSyncService.updateGameTime(_gameSessionId!, _timeInSeconds)
              .catchError((e) => print('Error updating time: $e'));
        }
      } else {
        // Points mode
        _elapsedSeconds++;
        
        // Sync elapsed time for Points mode (less frequently)
        if (_isHost && _elapsedSeconds % 2 == 0 && _gameSessionId != null) {
          // Don't await this - let it happen in background
          _gameSyncService.updateGameTime(_gameSessionId!, _elapsedSeconds)
              .catchError((e) => print('Error updating elapsed time: $e'));
        }
      }
      notifyListeners();
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
        
        //print("Vibration started"); // Debug print
      } catch (e) {
        print("Vibration error: $e"); // Debug print
      }
    } else {
      //print("No vibrator available"); // Debug print
    }
  }

  /// Gracefully terminates game session
  /// Cleans up resources and triggers callbacks
  Future<void> stopGame() async {
    // Add bypass check
    if (_debugBypassActiveCheck && _isGameActive) {
      print("Debug bypass active: game not stopped");
      return;
    }

    _isGameActive = false;
    
    // Cancel all timers
    _timer?.cancel();
    _flashTimer?.cancel();
    _vibrationTimer?.cancel();
    
    // Reset states
    _isFlashing = false;
    
    // Make sure vibration is completely stopped
    await Vibration.cancel();
    
    // Update the database
    if (_gameSessionId != null) {
      await _gameSyncService.endGame(_gameSessionId!);
    }

    try {
      // Reset debug values for both controllers
      if (navigatorKey.currentContext != null) {
        final player1Controller = Provider.of<CarControllerViewModel>(
          navigatorKey.currentContext!, 
          listen: false
        );
        final player2Controller = Provider.of<CarControllerViewModel>(
          navigatorKey.currentContext!, 
          listen: false
        );
        
        player1Controller.resetDebugValues();
        player2Controller.resetDebugValues();
      }
    } catch (e) {
      print('Error resetting debug values: $e');
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
    // Update locally first
    _player1Points++;
    
    // Notify UI immediately
    notifyListeners();
    
    // Check win condition
    _checkWinCondition();
    
    // Update server in background without awaiting
    if (_gameSessionId != null) {
      _gameSyncService.updateScore(_gameSessionId!, _player1Points, _player2Points)
          .catchError((e) => print('Error updating score: $e'));
    }
  }

  void addPointToPlayer2() {
    // Update locally first
    _player2Points++;
    
    // Notify UI immediately
    notifyListeners();
    
    // Check win condition
    _checkWinCondition();
    
    // Update server in background without awaiting
    if (_gameSessionId != null) {
      _gameSyncService.updateScore(_gameSessionId!, _player1Points, _player2Points)
          .catchError((e) => print('Error updating score: $e'));
    }
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
    // Exit immediately if game is already inactive
    if (!_isGameActive) return;
    
    bool shouldEndGame = false;
    
    if (_gameMode == 'Points' && _targetPoints != null) {
      // Check if either player has reached target points
      if (_player1Points >= _targetPoints!) {
        _winner = _player1Name;
        shouldEndGame = true;
        print("Player 1 reached target points: $_player1Points >= $_targetPoints");
      } else if (_player2Points >= _targetPoints!) {
        _winner = _player2Name;
        shouldEndGame = true;
        print("Player 2 reached target points: $_player2Points >= $_targetPoints");
      }
    } else if (_gameMode == 'Time' && _timeInSeconds >= _gameValue! * 60) {
      _determineWinnerForTimeMode();
      shouldEndGame = true;
      print("Time limit reached");
    }
    
    // If we should end the game, IMMEDIATELY disable inputs and timers
    if (shouldEndGame) {
      print("Game ending due to win condition");
      
      // CRITICAL: Immediately disable all inputs and stop timers
      _isGameActive = false;
      _timer?.cancel();
      _flashTimer?.cancel();
      _vibrationTimer?.cancel();
      _isFlashing = false;
      
      // Notify UI instantly to prevent additional input acceptance
      notifyListeners();
      
      // Now safely perform the full game ending process
      _endGame();
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
    _gameSyncService.dispose();
    _bluetoothService.dispose();
    _car1 = null;
    _car2 = null;
    
    _timer?.cancel();
    _flashTimer?.cancel();
    _vibrationTimer?.cancel();
    Vibration.cancel();
    super.dispose();
  }

  Future<void> _endGame() async {
    print("_endGame() called, is game active: $_isGameActive");
    
    // CRITICAL: Capture final time BEFORE cancelling timers
    _finalElapsedSeconds = _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds;
    
    // CRITICAL: Ensure all timers are immediately canceled
    _timer?.cancel();
    _timer = null; // Set to null to ensure it can't be used elsewhere
    
    _flashTimer?.cancel();
    _flashTimer = null;
    
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    
    _isFlashing = false;
    
    // Cancel vibrations immediately
    Vibration.cancel();
    
    // Ensure game is marked inactive
    _isGameActive = false;
    
    // Create a local copy of the winner to ensure consistency
    final localWinner = _winner;
    
    // Notify UI immediately to update visuals
    notifyListeners();
    
    // Run background tasks in parallel for efficiency
    Future.wait([
      // Update database
      _gameSessionId != null 
          ? _gameSyncService.endGame(_gameSessionId!)
          : Future.value(),
      
      // Save to leaderboard if available
      _saveToLeaderboard(localWinner),
      
      // Reset any controllers
      _resetControllers(),
    ]).catchError((e) => print('Error in background tasks: $e'));
    
    // Only call game over callback after local state is updated
    if (localWinner != null && _onGameOver != null) {
      _onGameOver!();
    }
  }

  Future<void> _saveToLeaderboard(String? localWinner) async {
  if (_leaderboardUpdated || 
      _leaderboardViewModel == null || 
      !_leaderboardViewModel!.isConnected || 
      localWinner == null ||
      localWinner == 'Draw') {
    return;
  }
  
  try {
    _leaderboardUpdated = true; // Mark as updated to prevent duplicates
    
    // Determine winner and loser
    String winnerName = localWinner;
    String loserName = winnerName == _player1Name ? _player2Name : _player1Name;
    int winnerScore = winnerName == _player1Name ? _player1Points : _player2Points;
    int loserScore = winnerName == _player1Name ? _player2Points : _player1Points;
    
    // Calculate duration in seconds
    int duration = _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds;
    
    // Create and save leaderboard entry
    LeaderboardEntry entry = LeaderboardEntry(
      winner: winnerName,
      loser: loserName,
      winnerScore: winnerScore,
      loserScore: loserScore,
      gameMode: _gameMode!,
      gameValue: _gameMode == 'Time' 
          ? _gameValue.toString() 
          : _targetPoints.toString(),
      timestamp: DateTime.now(),
      duration: duration,
    );
    
    await _leaderboardViewModel!.addEntry(entry);
    print("Game saved to leaderboard: Winner: $winnerName, Score: $winnerScore-$loserScore");
  } catch (e) {
    print("Error saving to leaderboard: $e");
  }
}

  /// Handles joystick input
  void handleJoystick(String carId, double x, double y) {
    if (!_isGameActive) return;
    _gameCommands.sendJoystickControl(carId, x, y);
  }

  /// Handles fire button
  void handleFireButton(String carId, bool isPressed) {
    if (!_isGameActive) return;
    _gameCommands.sendFire(carId, isPressed);
  }

  /// Handles brake button
  void handleBrakeButton(String carId, bool isPressed) {
    if (!_isGameActive) return;
    _gameCommands.sendBrake(carId, isPressed);
  }

  /// Handles hit events from cars
  void _handleHit(Map<String, dynamic> data) {
    // First, check if game is still active (fastest possible exit)
    if (!_isGameActive || _gameSessionId == null) return;
    
    final targetCar = data['target'];
    final isPlayer1Hit = targetCar == 'Car1';
    
    // CRITICAL: Make a local atomic update with final checks
    // This prevents multiple points from being applied during concurrent calls
    int currentPlayer1Points = _player1Points;
    int currentPlayer2Points = _player2Points;
    
    // Update local state optimistically but with atomic operation
    if (isPlayer1Hit) {
      currentPlayer2Points++;
      _player2Points = currentPlayer2Points;
    } else {
      currentPlayer1Points++;
      _player1Points = currentPlayer1Points;
    }
    
    // SYNCHRONIZATION LOCK: Immediately check if points threshold is reached
    if (_gameMode == 'Points' && _targetPoints != null) {
      if (currentPlayer1Points >= _targetPoints!) {
        // Player 1 wins - lock game state
        _winner = _player1Name;
        _isGameActive = false;  // Immediately lock the game state
        
        // Skip server update - we'll end the game
        notifyListeners();
        _endGame();
        return; // EXIT EARLY - don't process more
      }
      else if (currentPlayer2Points >= _targetPoints!) {
        // Player 2 wins - lock game state
        _winner = _player2Name;
        _isGameActive = false;  // Immediately lock the game state
        
        // Skip server update - we'll end the game
        notifyListeners();
        _endGame();
        return; // EXIT EARLY - don't process more
      }
    }
    
    // Notify UI immediately for responsive feedback
    notifyListeners();
    
    // Only if we're still active, update server
    if (_isGameActive && _gameSessionId != null) {
      _gameSyncService.recordHit(_gameSessionId!, isPlayer1Hit)
        .catchError((e) => print('Error recording hit: $e'));
    }
  }

  /// Connects a car to the game
  Future<void> connectCar(BluetoothDevice device) async {
    try {
      // Use bluetoothService directly for connection
      await _bluetoothService.setupMessageHandling(device.id);
      
      // Assign car based on type
      if (device.carType == CarType.car1) {
        setCar1(device);
      } else {
        setCar2(device);
      }
      
      notifyListeners();
    } catch (e) {
      print('Failed to connect car: $e');
    }
  }

  /// Disconnects a car from the game
  Future<void> disconnectCar(String carId) async {
    try {
      // Use bluetoothService to handle disconnection
      await _bluetoothService.dispose();
      
      // Clear car reference
      if (_car1?.id == carId) {
        setCar1(null);
      } else if (_car2?.id == carId) {
        setCar2(null);
      }
      
      notifyListeners();
    } catch (e) {
      print('Failed to disconnect car: $e');
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

  // Add this method to handle game updates
  void _handleGameUpdate(GameSession session) {
    // Update scores
    _player1Points = session.player1Score;
    _player2Points = session.player2Score;
    
    // Sync time if not host
    if (!_isHost) {
      if (_gameMode == 'Time') {
        _timeInSeconds = session.currentTimeSeconds;
      } else {
        _elapsedSeconds = session.currentTimeSeconds;
      }
    }
    
    // Check if the game was ended externally, but respect debug bypass flag
    if (!session.isActive && _isGameActive && !_debugBypassActiveCheck) {
      print("Game ended externally via Supabase");
      
      // Local game is still active but database says it's over
      _isGameActive = false;
      
      // CRITICAL: Cancel ALL timers and set to null to prevent reuse
      _timer?.cancel();
      _timer = null;
      
      _flashTimer?.cancel();
      _flashTimer = null;
      
      _vibrationTimer?.cancel();
      _vibrationTimer = null;
      
      _isFlashing = false;
      Vibration.cancel();
      
      // Determine winner if not already set
      if (_winner == null) {
        _determineWinnerForTimeMode();
      }
      
      // Only update leaderboard once
      if (!_leaderboardUpdated) {
        _updateLeaderboard();
        _leaderboardUpdated = true;
      }
      
      // Trigger game over callback
      if (_onGameOver != null) {
        _onGameOver!();
      }
    }
    
    notifyListeners();
  }

  // Add a method to join an existing game
  Future<bool> joinGame(String code, [String? joinerName]) async {
    try {
      _gameCode = code;
      _isGameActive = true; // Set active early for UI responsiveness
      
      // Start a parallel fetch of the session data
      final sessionFuture = _gameSyncService.getGameSession(code);
      
      // Prepare for the game by setting up local timer
      _gameSessionId = code;
      
      // Start timer immediately (optimistically)
      _startGameTimer();
      
      // Notify listeners for immediate UI update
      notifyListeners();
      
      // Now wait for session data
      final session = await sessionFuture;
      if (session == null) {
        // Rollback our optimistic updates
        _isGameActive = false;
        _timer?.cancel();
        notifyListeners();
        return false;
      }
      
      // Check if game is active, but allow debug bypass
      if (!session.isActive && !_debugBypassActiveCheck) {
        _isGameActive = false;
        _timer?.cancel();
        notifyListeners();
        return false;
      }
      
      // Setup game parameters
      _gameMode = session.gameMode;
      _gameValue = session.gameValue;
      
      // Initialize time based on session data
      if (_gameMode == 'Time') {
        _timeInSeconds = session.currentTimeSeconds;
      } else {
        _elapsedSeconds = session.currentTimeSeconds;
        if (_gameMode == 'Points') {
          _targetPoints = _gameValue;
        }
      }
      
      // Handle player names
      if (joinerName != null) {
        _player1Name = session.player1Name;
        _player2Name = joinerName;
        
        // Update player2 name in background
        _gameSyncService.updatePlayer2Name(_gameSessionId!, joinerName)
            .catchError((e) => print('Error updating player name: $e'));
        
        _isHost = false;
      } else {
        _player1Name = session.player1Name;
        _player2Name = session.player2Name;
      }
      
      // Subscribe to real-time updates
      _gameSyncService.subscribeToGame(_gameSessionId!);
      
      // Update scores from server
      _player1Points = session.player1Score;
      _player2Points = session.player2Score;
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error joining game: $e');
      _isGameActive = false;
      _timer?.cancel();
      notifyListeners();
      return false;
    }
  }

  /// Update player names based on whether the user is host or joiner
  void assignPlayerNamesByRole(String playerName) {
    if (_isHost) {
      // If host, use this player's name as player1
      player1Name = playerName;
      // Player2 name will be updated when the other player joins
    } else {
      // If joiner, use this player's name as player2
      player2Name = playerName;
      // Player1 name will come from the host
    }
    notifyListeners();
  }

  /// Public method to end game from external triggers
  Future<void> gameOver() async {
    if (!_isGameActive) return;
    
    // Add bypass check here too
    if (_debugBypassActiveCheck) {
      print("Debug bypass active: gameOver prevented");
      return;
    }
    
    // CRITICAL: Capture final time BEFORE cancelling timers
    _finalElapsedSeconds = _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds;
    
    // CRITICAL: Cancel all timers IMMEDIATELY to stop elapsed time
    _timer?.cancel();
    _timer = null;
    
    _flashTimer?.cancel();
    _flashTimer = null;
    
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    
    // Determine winner if not already set
    if (_winner == null) {
      _determineWinnerForTimeMode();
    }
    
    // Ensure game is inactive
    _isGameActive = false;
    
    // Notify UI
    notifyListeners();
    
    // Complete ending process
    await _endGame();
  }

  // Add this helper method
  Future<void> _updateLeaderboard() async {
    if (_leaderboardViewModel == null || !_leaderboardViewModel!.isConnected || _winner == null) {
      return;
    }
    
    try {
      if (_winner != "Draw") {
        // Determine winner and loser
        String winnerName = _winner!;
        String loserName = winnerName == _player1Name ? _player2Name : _player1Name;
        int winnerScore = winnerName == _player1Name ? _player1Points : _player2Points;
        int loserScore = winnerName == _player1Name ? _player2Points : _player1Points;
        
        // Calculate duration
        int duration = _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds;
        
        LeaderboardEntry entry = LeaderboardEntry(
          winner: winnerName,
          loser: loserName,
          winnerScore: winnerScore,
          loserScore: loserScore,
          gameMode: _gameMode!,
          gameValue: _gameMode == 'Time' ? _gameValue.toString() : _targetPoints.toString(),
          timestamp: DateTime.now(),
          duration: duration,
        );
        
        await _leaderboardViewModel!.addEntry(entry);
        print('Game recorded in leaderboard');
      }
    } catch (e) {
      print('Error updating leaderboard: $e');
    }
  }

  // Add this helper method to reset controllers
  Future<void> _resetControllers() async {
    try {
      if (navigatorKey.currentContext != null) {
        final player1Controller = Provider.of<CarControllerViewModel>(
          navigatorKey.currentContext!, 
          listen: false
        );
        final player2Controller = Provider.of<CarControllerViewModel>(
          navigatorKey.currentContext!, 
          listen: false
        );
        
        player1Controller.resetDebugValues();
        player2Controller.resetDebugValues();
      }
    } catch (e) {
      print('Error resetting debug values: $e');
    }
  }

  // Add this helper method to print debug status
  void printDebugStatus() {
    if (_debugBypassActiveCheck) {
      print("=== DEBUG STATUS ===");
      print("Debug bypass: ACTIVE");
      print("Game active: $_isGameActive");
      print("Game mode: $_gameMode");
      print("Game session ID: $_gameSessionId");
      print("==================");
    }
  }
}
