import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laser_car_battle/models/game_session.dart';

// Add this new function type near the top of the file
typedef GameStartCallback = void Function(String? startTimeString);

/// Service responsible for handling real-time game synchronization between players
/// using Supabase's Realtime features and database operations.
class GameSyncService {
  final SupabaseClient _supabase; // Supabase client for database operations
  RealtimeChannel? _gameChannel; // Channel for real-time communication
  final Function(GameSession) onGameUpdate; // Callback for game state updates
  final Function(bool) onHit; // Callback triggered when a player is hit
  
  // Add a list of callbacks for game start events
  final List<GameStartCallback> _gameStartListeners = [];

  /// Constructor requiring Supabase client and callbacks for game events
  GameSyncService(this._supabase, {
    required this.onGameUpdate,
    required this.onHit,
  });
  
  // Add this method to register game start listeners
  void addGameStartListener(GameStartCallback callback) {
    _gameStartListeners.add(callback);
  }

  /// Creates a new game session in the database
  /// Returns the created GameSession with server-generated values
  Future<GameSession> createGameSession(GameSession session) async {
    final response = await _supabase
        .from('game_sessions')
        .insert(session.toJson())
        .select()
        .single();
    return GameSession.fromJson(response);
  }

  /// Creates a waiting room for a game session
  Future<GameSession> createWaitingRoom(GameSession session) async {
    // Create a temporary placeholder start time that will be updated when game truly starts
    final now = DateTime.now();
    
    final sessionWithWaiting = GameSession(
      id: session.id,
      player1Id: session.player1Id,
      player2Id: session.player2Id,
      player1Name: session.player1Name,
      player2Name: session.player2Name,
      gameMode: session.gameMode,
      gameValue: session.gameValue,
      startTime: now, // Use placeholder time
      isActive: true,
      waitingForPlayers: true, // Explicitly set to true
    );
    
    print("Creating waiting room with data: ${sessionWithWaiting.toJson()}");
    
    try {
      final response = await _supabase
          .from('game_sessions')
          .insert(sessionWithWaiting.toJson())
          .select()
          .single();
          
      print("Waiting room created response: $response");
      
      final createdSession = GameSession.fromJson(response);
      
      // Verify the session was created with waiting_for_players set to true
      print("Created session waiting status: ${createdSession.waitingForPlayers}");
      
      return createdSession;
    } catch (e) {
      print("Error creating waiting room: $e");
      rethrow;
    }
  }
  
  /// Starts a game that was in waiting state
  Future<void> startWaitingGame(String gameId) async {
    try {
      final startTime = DateTime.now().toUtc();
      
      print("Starting game $gameId with start time: $startTime");
      
      await _supabase.from('game_sessions').update({
        'waiting_for_players': false,
        'start_time': startTime.toIso8601String(),
        'current_time_seconds': 0, // Ensure timer starts at zero
      }).eq('id', gameId);
      
      print("Game session updated in database");
      
      // Broadcast game start event with the precise start time
      if (_gameChannel != null) {
        await _gameChannel!.sendBroadcastMessage(
          event: 'game_start',
          payload: {'start_time': startTime.toIso8601String()},
        );
        print("Game start broadcast sent");
      }
    } catch (e) {
      print("Error starting waiting game: $e");
    }
  }
  
  /// Checks if a second player has joined
  Future<bool> hasPlayerJoined(String gameId) async {
    try {
      final response = await _supabase
          .from('game_sessions')
          .select('player2_name')
          .eq('id', gameId)
          .single();
          
      // Check if player2_name is not null and not empty
      return response['player2_name'] != 'Player 2' && 
             response['player2_name'].toString().isNotEmpty;
    } catch (e) {
      print('Error checking for joined players: $e');
      return false;
    }
  }

  /// Sets up real-time subscription for a specific game
  /// Listens for game updates and hit events
  void subscribeToGame(String gameId) {
    // Create a channel for this specific game with a unique channel name
    _gameChannel = _supabase.realtime.channel('game_$gameId');
    
    // Listen for database changes on the game_sessions table
    // Only for the specific game matching the gameId
    _gameChannel?.onPostgresChanges(
      event: PostgresChangeEvent.update, // Only interested in updates
      schema: 'public',
      table: 'game_sessions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: gameId,
      ),
      callback: (payload) {
        // Convert the updated record to a GameSession object
        final updatedGame = GameSession.fromJson(Map<String, dynamic>.from(payload.newRecord));
        onGameUpdate(updatedGame); // Notify listeners about the game update
      },
    );
    
    // Subscribe to broadcast messages for hit events
    // This allows for immediate hit notifications without database polling
    _gameChannel?.onBroadcast(
      event: 'hit',
      callback: (payload) {
        if (payload['player_hit'] != null) {
          final playerHit = payload['player_hit'] as bool;
          onHit(playerHit); // Notify listeners about the hit event
        }
      },
    );
    
    // Add handler for game_start events
    _gameChannel?.onBroadcast(
      event: 'game_start',
      callback: (payload) {
        if (payload['start_time'] != null) {
          final startTime = payload['start_time'] as String;
          // Notify all registered listeners
          for (var listener in _gameStartListeners) {
            listener(startTime);
          }
        }
      },
    );
    
    // Activate the channel subscription
    _gameChannel?.subscribe();
  }

  /// Updates the scores for both players in the database
  Future<void> updateScore(String gameId, int player1Score, int player2Score) async {
    await _supabase.from('game_sessions').update({
      'player1_score': player1Score,
      'player2_score': player2Score,
    }).eq('id', gameId);
  }

  /// Marks a game as ended with the current timestamp
  Future<void> endGame(String gameId) async {
    try {
      await _supabase.from('game_sessions').update({
        'is_active': false,
        'end_time': DateTime.now().toIso8601String(),
      }).eq('id', gameId);
      
      print('Game session $gameId marked as inactive');
    } catch (e) {
      print('Error ending game session: $e');
    }
  }

  /// Records a player hit, increments the appropriate score,
  /// and broadcasts the hit event to all connected clients
  Future<void> recordHit(String gameId, bool isPlayer1Hit) async {
    // Determine which player was hit and update the opponent's score
    if (isPlayer1Hit) {
      // If player 1 was hit, increment player 2's score
      // First get current score to avoid race conditions
      final response = await _supabase
          .from('game_sessions')
          .select('player2_score')
          .eq('id', gameId)
          .single();
      
      int currentScore = response['player2_score'] ?? 0;
      
      // Update the score in the database
      await _supabase.from('game_sessions').update({
        'player2_score': currentScore + 1
      }).eq('id', gameId);
    } else {
      // If player 2 was hit, increment player 1's score
      final response = await _supabase
          .from('game_sessions')
          .select('player1_score')
          .eq('id', gameId)
          .single();
      
      int currentScore = response['player1_score'] ?? 0;
      
      // Update the score in the database
      await _supabase.from('game_sessions').update({
        'player1_score': currentScore + 1
      }).eq('id', gameId);
    }

    // Broadcast the hit event to all clients subscribed to this game channel
    // This provides immediate feedback without waiting for database sync
    if (_gameChannel != null) {
      try {
        await _gameChannel!.sendBroadcastMessage(
          event: 'hit',
          payload: {'player_hit': isPlayer1Hit}, // Indicate which player was hit
        );
      } catch (error) {
        print('Error sending hit event: $error');
      }
    }
  }

  /// Fetches a game session by its ID
  Future<GameSession?> getGameSession(String gameId) async {
    try {
      final response = await _supabase
          .from('game_sessions')
          .select()
          .eq('id', gameId)
          .single();
      return GameSession.fromJson(response);
    } catch (e) {
      print('Error fetching game session: $e');
      return null;
    }
  }

  /// Fetches all active game sessions from the database
  /// Returns a list of GameSession objects for games still in progress
  Future<List<GameSession>> getActiveGameSessions() async {
    try {
      final response = await _supabase
          .from('game_sessions')
          .select()
          .eq('is_active', true)
          .order('start_time', ascending: false); // Most recent games first
      
      // Convert the response to a list of GameSession objects
      return (response as List<dynamic>)
          .map((game) => GameSession.fromJson(game))
          .toList();
    } catch (e) {
      print('Error fetching active game sessions: $e');
      return []; // Return empty list on error
    }
  }

  /// Updates the waiting status of a game session
Future<void> updateWaitingStatus(String gameId, bool waitingStatus) async {
  try {
    await _supabase.from('game_sessions').update({
      'waiting_for_players': waitingStatus,
    }).eq('id', gameId);
    
    print("Updated waiting status to $waitingStatus for game $gameId");
  } catch (e) {
    print("Error updating waiting status: $e");
    rethrow;
  }
}

  /// Fetches all games currently waiting for players to join
  Future<List<GameSession>> getWaitingGames() async {
    try {
      print('Fetching waiting games from Supabase...');
      
      // Skip the column check and go directly to the query
      final response = await _supabase
          .from('game_sessions')
          .select()
          .eq('waiting_for_players', true)
          .eq('is_active', true);
      
      print('Raw response: $response');
      
      // Convert the response to a list of GameSession objects
      final games = (response as List)
          .map((game) => GameSession.fromJson(game))
          .toList();
          
      print('Parsed ${games.length} waiting games');
      return games;
    } catch (e) {
      print('Error fetching waiting games: $e');
      
      // Check if this is specifically about the missing column
      if (e.toString().contains('column "waiting_for_players" does not exist')) {
        print('The waiting_for_players column needs to be added to your database');
        
        // Return empty list since column doesn't exist
        return [];
      }
      
      return []; // Return empty list on any other error
    }
  }

  /// Updates player2's name when they join the game
  Future<void> updatePlayer2Name(String gameId, String player2Name) async {
    await _supabase.from('game_sessions').update({
      'player2_name': player2Name,
    }).eq('id', gameId);
  }

  /// Updates the current time in the game session
  Future<void> updateGameTime(String gameId, int timeSeconds) async {
    try {
      // Use update to ensure atomicity
      await _supabase.from('game_sessions').update({
        'current_time_seconds': timeSeconds,
      }).eq('id', gameId);
    } catch (e) {
      print('Error updating game time: $e');
    }
  }

  /// Cleanup method to unsubscribe from the realtime channel
  /// Should be called when the game ends or the screen is disposed
  void dispose() {
    _gameChannel?.unsubscribe();
  }
}