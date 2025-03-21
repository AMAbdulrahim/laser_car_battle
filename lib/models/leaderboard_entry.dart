import 'package:laser_car_battle/models/game_session.dart';

class LeaderboardEntry {
  final String winner;      // Winner's name
  final String loser;       // Loser's name
  final int winnerScore;    // Winner's final score
  final int loserScore;     // Loser's final score
  final String gameMode;    // "Time" or "Points"
  final String? gameValue;  // Target points or time limit (as string)
  final DateTime timestamp; // When the game ended
  final int? duration;      // Game duration in seconds

  LeaderboardEntry({
    required this.winner,
    required this.loser,
    required this.winnerScore,
    required this.loserScore,
    required this.gameMode,
    this.gameValue,
    required this.timestamp,
    this.duration,
  });

  // Ensure toJson includes the duration field
  Map<String, dynamic> toJson() {
    return {
      'winner': winner,
      'loser': loser,
      'winner_score': winnerScore,
      'loser_score': loserScore,
      'game_mode': gameMode,
      'game_value': gameValue,
      'created_at': timestamp.toIso8601String(),
      'duration': duration,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      winner: json['winner'] ?? '',
      loser: json['loser'] ?? '',
      winnerScore: json['winner_score'] ?? 0,
      loserScore: json['loser_score'] ?? 0,
      gameMode: json['game_mode'] ?? 'Unknown',
      gameValue: json['game_value']?.toString(),
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      duration: json['duration'],
    );
  }
  
  // Helper method to create entry from GameSession
  static LeaderboardEntry fromGameSession(
    GameSession session, 
    String winner,
    String loser,
    int winnerScore, 
    int loserScore
  ) {
    return LeaderboardEntry(
      winner: winner,
      loser: loser,
      winnerScore: winnerScore,
      loserScore: loserScore,
      gameMode: session.gameMode,
      gameValue: session.gameValue.toString(),
      timestamp: DateTime.now(),
      duration: session.currentTimeSeconds,
    );
  }
}