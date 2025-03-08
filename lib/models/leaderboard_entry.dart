class LeaderboardEntry {
  final String winner;
  final String loser;
  final int winnerScore;
  final int loserScore;
  final String gameMode;
  final String? gameValue;
  final DateTime timestamp;
  final int? duration; // Make nullable since older entries won't have it

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
}