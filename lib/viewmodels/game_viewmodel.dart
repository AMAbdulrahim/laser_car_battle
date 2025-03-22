// ignore_for_file: avoid_print

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
import 'package:http/http.dart' as http;

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

  // Add these fields
  bool _waitingForPlayers = false;
  bool get waitingForPlayers => _waitingForPlayers;
  Timer? _waitingRoomTimer;
  DateTime? _gameStartTimeUTC;

  // Add these properties near other game state properties
  int _finalPlayer1Points = 0;
  int _finalPlayer2Points = 0;
  
  // First, add a flag to track if vibration is active
  bool _vibrationActive = false;
  
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

  // Add getters for the final scores
  int get finalPlayer1Points => _finalPlayer1Points;
  int get finalPlayer2Points => _finalPlayer2Points;

  /// Initializes and starts the game session
  /// Sets up timers, resets state, and manages game flow
  Future<String> startGame() async {
    // Reset states first
    _player1Points = 0;
    _player2Points = 0;
    _timeInSeconds = 0;
    _elapsedSeconds = 0;
    _winner = null;
    _leaderboardUpdated = false;
    
    // Cancel any existing timers
    _timer?.cancel();
    _flashTimer?.cancel();
    _waitingRoomTimer?.cancel();
    
    // Generate game code for host
    if (isHost) {
      _gameCode = _generateGameCode();
      _waitingForPlayers = true; // Host will wait for players
    }
    
    // For UI responsiveness
    notifyListeners();
    
    // Handle the network operations
    if (isHost) {
      // Create a waiting room session
      final session = GameSession(
        id: _gameCode!,
        player1Id: _car1?.id ?? 'mock-car1-id',
        player2Id: _car2?.id ?? 'mock-car2-id',
        player1Name: _player1Name,
        player2Name: _player2Name,
        gameMode: _gameMode!,
        gameValue: _gameValue ?? _targetPoints!,
        startTime: DateTime.now(), // Placeholder, will update on actual start
        waitingForPlayers: true,
      );
      
      // Create a waiting game session
      final createdSession = await _gameSyncService.createWaitingRoom(session);
      _gameSessionId = createdSession.id;
      
      // Subscribe to the game channel
      _gameSyncService.subscribeToGame(_gameSessionId!);
      
      // Start polling for joined player
      _startWaitingRoomPolling();
      
      return _gameCode!;
    } else {
      // For non-host players, just join the game
      _gameSessionId = _gameCode;
      _gameSyncService.subscribeToGame(_gameSessionId!);
      
      // Wait for game start signal
      _listenForGameStart();
      
      return _gameCode!;
    }
  }

 // In GameViewModel's startWaitingRoomPolling method
void _startWaitingRoomPolling() {
  // First verify the waiting status is correctly set
  _verifyWaitingStatus();
  
  _waitingRoomTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
    bool playerJoined = await _gameSyncService.hasPlayerJoined(_gameSessionId!);
    
    if (playerJoined) {
      // Player has joined, start the game!
      print("Player 2 has joined! Starting the game.");
      timer.cancel();
      _startActualGame();
    }
  });
}

// Add this verification method
// Replace this method with the corrected version
Future<void> _verifyWaitingStatus() async {
  try {
    // Get the current session state
    final session = await _gameSyncService.getGameSession(_gameSessionId!);
    
    if (session != null) {
      print("Current waiting status: ${session.waitingForPlayers}");
      
      // If it's not in waiting state but should be, fix it
      if (!session.waitingForPlayers && _waitingForPlayers) {
        print("Fixing incorrect waiting status...");
        // Use the GameSyncService instead of directly accessing _supabase
        await _gameSyncService.updateWaitingStatus(_gameSessionId!, true);
      }
    }
  } catch (e) {
    print("Error verifying waiting status: $e");
  }
}

  // Add this method to start the game once players have joined
Future<void> _startActualGame() async {
  // Cancel the waiting timer
  _waitingRoomTimer?.cancel();
  _waitingForPlayers = false;
  
  print("Starting actual game - player has joined");
  
  // Reset timers and counters before starting
  _timeInSeconds = 0;
  _elapsedSeconds = 0;
  _player1Points = 0;
  _player2Points = 0;
  
  // Set the start time and notify Supabase
  final startTimeUtc = DateTime.now().toUtc();
  _gameStartTimeUTC = startTimeUtc;
  
  // Set the game as active
  _isGameActive = true;
  
  // Let Supabase know the game has started with explicit waiting_for_players=false
  try {
    await _gameSyncService.startWaitingGame(_gameSessionId!);
    print("Game marked as started in Supabase");
  } catch (e) {
    print("Error updating game start status: $e");
  }
  
  // Start the local timer only AFTER database is updated
  _startLocalGameTimer();
  
  // Send game start commands to cars
  if (_car1?.id != null) {
    await _gameCommands.sendGameStart(
      _car1!.id,
      gameMode: _gameMode!,
      gameValue: _gameValue ?? _targetPoints!,
      playerName: _player1Name,
    ).catchError((e) => print('Error sending to car 1: $e'));
  }
  
  if (_car2?.id != null) {
    await _gameCommands.sendGameStart(
      _car2!.id,
      gameMode: _gameMode!,
      gameValue: _gameValue ?? _targetPoints!,
      playerName: _player2Name,
    ).catchError((e) => print('Error sending to car 2: $e'));
  }
  
  // Update UI
  notifyListeners();
}

  // Add this method to listen for game start
  void _listenForGameStart() {
  // Register a listener for game start events through the GameSyncService
  _gameSyncService.addGameStartListener((startTimeString) {
    if (startTimeString != null) {
      // Parse the start time
      _gameStartTimeUTC = DateTime.parse(startTimeString);
      
      // Start the game locally
      _isGameActive = true;
      _startLocalGameTimer();
      notifyListeners();
    }
  });
}

  // Replace the previous timer with this version that calculates based on start time
  // Replace the previous timer with this version that calculates based on start time
void _startLocalGameTimer() {
  // Make sure we have a game start time
  _gameStartTimeUTC ??= DateTime.now().toUtc();
  
  // Explicitly reset counters
  _timeInSeconds = 0;
  _elapsedSeconds = 0;
  
  print("Starting local timer with start time: $_gameStartTimeUTC");
  
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    // Calculate elapsed time from the start time
    final now = DateTime.now().toUtc();
    final elapsedSeconds = now.difference(_gameStartTimeUTC!).inSeconds;
    
    if (_gameMode == 'Time') {
      _timeInSeconds = elapsedSeconds;
      
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
    } else {
      // Points mode
      _elapsedSeconds = elapsedSeconds;
    }
    
    // If we're the host, update time in database periodically
    if (_isHost && _gameSessionId != null && elapsedSeconds % 5 == 0) {
      int timeToUpdate = _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds;
      _gameSyncService.updateGameTime(_gameSessionId!, timeToUpdate)
        .catchError((e) => print("Error updating time: $e"));
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
        _vibrationActive = true; // Mark that vibration is active
        
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
  
  // Use the reliable vibration stop method
  await _ensureVibrationStopped();
  
  // Update the database
  if (_gameSessionId != null) {
    await _gameSyncService.endGame(_gameSessionId!);
  }

  // Reset player names to defaults
  _player1Name = 'Player 1';
  _player2Name = 'Player 2';

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
  _elapsedSeconds = 0;
  _timer?.cancel();
  _isGameActive = false;
  _flashTimer?.cancel();
  _vibrationTimer?.cancel();
  _isFlashing = false;
  Vibration.cancel();
  _winner = null;
  
  // Reset player names to defaults
  _player1Name = 'Player 1';
  _player2Name = 'Player 2';
  
  // Reset game session related fields
  _gameSessionId = null;
  _gameCode = null;
  _waitingForPlayers = false;
  
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
    _waitingRoomTimer?.cancel();
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

  // Add this new method to handle network errors with retry
  Future<void> _updateDatabaseWithRetry() async {
    // First check if we have connectivity
    final hasConnectivity = await _hasNetworkConnectivity();
    if (!hasConnectivity) {
      print("No network connectivity detected. Skipping database update.");
      return;
    }

    // Set a max number of retries
    const maxRetries = 3;
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        await _gameSyncService.endGame(_gameSessionId!);
        print("Successfully ended game in database");
        return; // Success! Exit the method
      } catch (e) {
        attempts++;
        print("Network error ending game (attempt $attempts/$maxRetries): $e");
        
        // Only wait and retry if we haven't hit max attempts
        if (attempts < maxRetries) {
          // Exponential backoff: wait longer with each retry
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        }
      }
    }
    
    // If we got here, all attempts failed
    print("Failed to update database after $maxRetries attempts. Game will end locally only.");
  }

  // Replace the database call in _endGame with this new method
  Future<void> _endGame() async {
  print("_endGame() called, is game active: $_isGameActive");
  
  // CRITICAL: Capture final values BEFORE cancelling timers
  _finalElapsedSeconds = _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds;
  
  // NEW: Capture final scores
  _finalPlayer1Points = _player1Points;
  _finalPlayer2Points = _player2Points;
  
  // Save player names to local variables before resetting
  final player1NameFinal = _player1Name;
  final player2NameFinal = _player2Name;
  final localWinner = _winner;
  
  // CRITICAL: Ensure all timers are immediately canceled
  _timer?.cancel();
  _timer = null; // Set to null to ensure it can't be used elsewhere
  
  _flashTimer?.cancel();
  _flashTimer = null;
  
  _vibrationTimer?.cancel();
  _vibrationTimer = null;
  
  _isFlashing = false;
  
  // Use the new helper method to reliably stop vibration
  await _ensureVibrationStopped();
  
  // Cancel vibrations immediately
  Vibration.cancel();
  
  // Ensure game is marked inactive
  _isGameActive = false;
  
  // Reset game session related fields
  // Keep _gameSessionId until we finish with database updates
  // _gameSessionId = null;
  _gameCode = null;
  _waitingForPlayers = false;
  
  // Important: Reset player names to defaults AFTER saving them for leaderboard
  _player1Name = 'Player 1';
  _player2Name = 'Player 2';
  
  // Notify UI immediately to update visuals
  notifyListeners();
  
  // Run background tasks in parallel for efficiency
  await Future.wait([
    // Update database with retry mechanism
    _gameSessionId != null 
        ? _updateDatabaseWithRetry()
        : Future.value(),
    
    // Save to leaderboard if available - use the saved final names
    _saveToLeaderboardWithNames(localWinner, player1NameFinal, player2NameFinal),
    
    // Reset any controllers
    _resetControllers(),
  ]).catchError((e) => print('Error in background tasks: $e'));

  // Now that database work is done, clear the session ID
  _gameSessionId = null;
  
  // Only call game over callback after local state is updated
  if (localWinner != null && _onGameOver != null) {
    _onGameOver!();
  }
}

  Future<void> _saveToLeaderboardWithNames(String? localWinner, String player1NameFinal, String player2NameFinal) async {
  if (_leaderboardUpdated || 
      _leaderboardViewModel == null || 
      !_leaderboardViewModel.isConnected || 
      localWinner == null) {
    return;
  }
  
  try {
    _leaderboardUpdated = true; // Mark as updated to prevent duplicates
    
    if (localWinner == 'Draw') {
      // Handle draw case
      LeaderboardEntry entry = LeaderboardEntry(
        winner: player1NameFinal, // Use saved name 
        loser: player2NameFinal,  // Use saved name
        winnerScore: _finalPlayer1Points, // Use final captured scores
        loserScore: _finalPlayer2Points,
        gameMode: _gameMode!,
        gameValue: _gameMode == 'Time' 
            ? _gameValue.toString() 
            : _targetPoints.toString(),
        timestamp: DateTime.now(),
        duration: _finalElapsedSeconds, // Use the captured final time
      );
      
      await _leaderboardViewModel.addEntry(entry);
      print("Draw game saved to leaderboard: Score: $_finalPlayer1Points-$_finalPlayer2Points");
    } else {
      // Determine winner and loser using the saved names
      String winnerName = localWinner;
      String loserName = winnerName == player1NameFinal ? player2NameFinal : player1NameFinal;
      int winnerScore = winnerName == player1NameFinal ? _finalPlayer1Points : _finalPlayer2Points;
      int loserScore = winnerName == player1NameFinal ? _finalPlayer2Points : _finalPlayer1Points;
      
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
        duration: _finalElapsedSeconds, // Use the captured final time
      );
      
      await _leaderboardViewModel.addEntry(entry);
      print("Game saved to leaderboard: Winner: $winnerName, Score: $winnerScore-$loserScore");
    }
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
      
      // Get the session data
      final session = await _gameSyncService.getGameSession(code);
      if (session == null) {
        return false;
      }
      
      // Check if game is in waiting state or active
      if (session.waitingForPlayers) {
        // Join the waiting game
        _gameSessionId = code;
        _gameMode = session.gameMode;
        _gameValue = session.gameValue;
        
        // Set player names
        _player1Name = session.player1Name;
        if (joinerName != null) {
          _player2Name = joinerName;
          // Update player2 name in the session
          await _gameSyncService.updatePlayer2Name(_gameSessionId!, joinerName);
        } else {
          _player2Name = session.player2Name;
        }
        
        // Subscribe and listen for game start
        _gameSyncService.subscribeToGame(_gameSessionId!);
        _listenForGameStart();
        
        _isHost = false;
        notifyListeners();
        return true;
      } 
      // If game is already active
      else if (session.isActive || _debugBypassActiveCheck) {
        // The old code for joining an active game...
        _isGameActive = true;
        _gameSessionId = code;
        _gameMode = session.gameMode;
        _gameValue = session.gameValue;
        
        // Get the start time from the session
        _gameStartTimeUTC = session.startTime.toUtc();
        
        // Initialize time based on the start time
        final now = DateTime.now().toUtc();
        final elapsedSeconds = now.difference(_gameStartTimeUTC!).inSeconds;
        
        if (_gameMode == 'Time') {
          _timeInSeconds = elapsedSeconds;
        } else {
          _elapsedSeconds = elapsedSeconds;
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
        } else {
          _player1Name = session.player1Name;
          _player2Name = session.player2Name;
        }
        
        // Subscribe to real-time updates
        _gameSyncService.subscribeToGame(_gameSessionId!);
        
        // Update scores from server
        _player1Points = session.player1Score;
        _player2Points = session.player2Score;
        
        // Start the local timer
        _startLocalGameTimer();
        
        _isHost = false;
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error joining game: $e');
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
  if (_leaderboardViewModel == null || !_leaderboardViewModel.isConnected || _winner == null) {
    return;
  }
  
  try {
    if (_winner == "Draw") {
      // Handle draw case
      LeaderboardEntry entry = LeaderboardEntry(
        winner: "Draw",
        loser: "Draw", // Use "Draw" as loser too or "N/A"
        winnerScore: _player1Points, // Both scores are equal in a draw
        loserScore: _player2Points,  // Include both scores for reference
        gameMode: _gameMode!,
        gameValue: _gameMode == 'Time' ? _gameValue.toString() : _targetPoints.toString(),
        timestamp: DateTime.now(),
        duration: _gameMode == 'Time' ? _timeInSeconds : _elapsedSeconds,
      );
      
      await _leaderboardViewModel.addEntry(entry);
      print('Draw game recorded in leaderboard');
    } else {
      // Existing code for winner/loser scenario
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
      
      await _leaderboardViewModel.addEntry(entry);
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

  // Create a robust method to ensure vibration stops
  Future<void> _ensureVibrationStopped() async {
    if (_vibrationActive) {
      try {
        await Vibration.cancel();
        _vibrationActive = false;
        print("Vibration explicitly stopped");
      } catch (e) {
        print("Error stopping vibration: $e");
        // Try again with a slight delay as a fallback
        await Future.delayed(Duration(milliseconds: 100));
        try {
          await Vibration.cancel();
          _vibrationActive = false;
        } catch (_) {}
      }
    }
  }

  // Add this method to check network connectivity (requires connectivity_plus package)
  Future<bool> _hasNetworkConnectivity() async {
  try {
    // Create a client that allows timeout settings
    final client = http.Client();
    try {
      // Use the client.get method with a timeout
      final response = await client.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } finally {
      client.close(); // Always close the client
    }
  } catch (e) {
    print("Network connectivity check failed: $e");
    return false;
  }
}

  /// Fetches available waiting games from the server
  Future<List<GameSession>> getWaitingGamesFromServer() async {
    try {
      // Create a GameSyncService with dummy callbacks if not already initialized
      final gameSyncService = _gameSyncService;
      
      // Get waiting games
      final games = await gameSyncService.getWaitingGames();
      return games;
    } catch (e) {
      print('Error in getWaitingGamesFromServer: $e');
      return []; // Return empty list on error
    }
  }
}
