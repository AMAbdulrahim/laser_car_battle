import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:laser_car_battle/models/game_session.dart';

/// Service responsible for handling real-time game synchronization between players
/// using Supabase's Realtime features and database operations.
class GameSyncService {
  final SupabaseClient _supabase; // Supabase client for database operations
  RealtimeChannel? _gameChannel; // Channel for real-time communication
  final Function(GameSession) onGameUpdate; // Callback for game state updates
  final Function(bool) onHit; // Callback triggered when a player is hit

  /// Constructor requiring Supabase client and callbacks for game events
  GameSyncService(this._supabase, {
    required this.onGameUpdate,
    required this.onHit,
  });

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