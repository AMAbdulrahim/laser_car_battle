import 'package:flutter/material.dart';
import 'package:laser_car_battle/models/leaderboard_entry.dart';
import 'package:laser_car_battle/widgets/leaderboard_entry_card.dart';

class LeaderboardEntriesList extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardEntriesList({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return LeaderboardEntryCard(entry: entry);
      },
    );
  }
}