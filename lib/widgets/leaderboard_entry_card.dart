import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/models/leaderboard_entry.dart';
import 'package:laser_car_battle/utils/helpers.dart';

class LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardEntryCard({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: CustomColors.mainButton,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          title: Text(
            '${entry.winner} vs ${entry.loser}',
            style: TextStyle(color: CustomColors.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score and game mode
              Text(
                '${entry.winnerScore} - ${entry.loserScore} (${entry.gameMode})',
                style: TextStyle(color: CustomColors.textPrimary.withOpacity(0.7)),
              ),
              SizedBox(height: 4),
              // Game value/duration info
              Row(
                children: [
                  // Show game value (e.g., "First to 10" or "Time: 5 minutes")
                  if (entry.gameValue != null)
                    Text(
                      formatGameInfo(entry.gameMode, entry.gameValue!),
                      style: TextStyle(
                        color: CustomColors.textPrimary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  
                  // Show duration if available
                  if (entry.duration != null) ...[
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: CustomColors.textPrimary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      entry.gameMode == 'Points' 
                          ? 'Duration: ${formatDuration(entry.duration!)}'
                          : 'Completed in: ${formatDuration(entry.duration!)}',
                      style: TextStyle(
                        color: CustomColors.textPrimary.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Container(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formatDate(entry.timestamp),
                  style: TextStyle(color: CustomColors.textPrimary),
                ),
                Text(
                  formatTime(entry.timestamp),
                  style: TextStyle(
                    color: CustomColors.textPrimary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}