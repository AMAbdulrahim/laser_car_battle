/// Model representing a game session between two players
class GameSession {
  /// Unique identifier for this game session
  final String id;
  
  /// Identifier for player 1's car
  final String player1Id;
  
  /// Identifier for player 2's car
  final String player2Id;
  
  /// Display name for player 1
  final String player1Name;
  
  /// Display name for player 2
  final String player2Name;
  
  /// The game mode (e.g., "Time" or "Points")
  final String gameMode;
  
  /// The game value (time limit in minutes or target points)
  final int gameValue;
  
  /// The timestamp when the game started
  final DateTime startTime;
  
  /// The timestamp when the game ended (null if game is ongoing)
  final DateTime? endTime;
  
  /// Whether the game is currently active
  final bool isActive;
  
  /// Player 1's current score
  final int player1Score;
  
  /// Player 2's current score
  final int player2Score;

  /// Current elapsed seconds (time state)
  final int currentTimeSeconds;

  /// Creates a new GameSession
  GameSession({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.player1Name,
    required this.player2Name,
    required this.gameMode,
    required this.gameValue,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    this.player1Score = 0,
    this.player2Score = 0,
    this.currentTimeSeconds = 0,
  });

  /// Creates a GameSession from JSON data received from the database
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'],
      player1Id: json['player1_id'],
      player2Id: json['player2_id'],
      player1Name: json['player1_name'],
      player2Name: json['player2_name'],
      gameMode: json['game_mode'],
      gameValue: json['game_value'],
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : null,
      isActive: json['is_active'] ?? true,
      player1Score: json['player1_score'] ?? 0,
      player2Score: json['player2_score'] ?? 0,
      currentTimeSeconds: json['current_time_seconds'] ?? 0,
    );
  }

  /// Converts this GameSession to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player1_id': player1Id,
      'player2_id': player2Id,
      'player1_name': player1Name,
      'player2_name': player2Name,
      'game_mode': gameMode,
      'game_value': gameValue,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'is_active': isActive,
      'player1_score': player1Score,
      'player2_score': player2Score,
      'current_time_seconds': currentTimeSeconds,
    };
  }

  /// Creates a copy of this GameSession with specified fields updated
  GameSession copyWith({
    String? id,
    String? player1Id,
    String? player2Id,
    String? player1Name,
    String? player2Name,
    String? gameMode,
    int? gameValue,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    int? player1Score,
    int? player2Score,
    int? currentTimeSeconds,
  }) {
    return GameSession(
      id: id ?? this.id,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      gameMode: gameMode ?? this.gameMode,
      gameValue: gameValue ?? this.gameValue,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      currentTimeSeconds: currentTimeSeconds ?? this.currentTimeSeconds,
    );
  }

  @override
  String toString() {
    return 'GameSession(id: $id, player1: $player1Name, player2: $player2Name, '
           'score: $player1Score-$player2Score, mode: $gameMode)';
  }
}