import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/viewmodels/leaderboard_viewmodel.dart';

class LeaderboardFilterPanel extends StatefulWidget {
  final LeaderboardViewModel viewModel;
  final String currentSortOption;
  final String currentGameModeFilter;
  final Function(String) onSortChanged;
  final Function(String) onGameModeChanged;
  final VoidCallback onResetFilters;

  const LeaderboardFilterPanel({
    Key? key,
    required this.viewModel,
    required this.currentSortOption,
    required this.currentGameModeFilter,
    required this.onSortChanged,
    required this.onGameModeChanged,
    required this.onResetFilters,
  }) : super(key: key);

  @override
  _LeaderboardFilterPanelState createState() => _LeaderboardFilterPanelState();
}

class _LeaderboardFilterPanelState extends State<LeaderboardFilterPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CustomColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - Sort options and reset
          Row(
            children: [
              Text(
                'Sort By',
                style: TextStyle(
                  color: CustomColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              // Reset button moved to top right
              _buildIconButton(
                icon: Icons.refresh,
                label: 'Reset',
                onTap: widget.onResetFilters,
              ),
            ],
          ),
          SizedBox(height: 6),
          // Sort options in a row - compact chips
          Row(
            children: [
              _buildCompactChip(
                label: 'Recent',
                isSelected: widget.currentSortOption == 'Most Recent',
                icon: Icons.access_time,
                onTap: () {
                  widget.onSortChanged('Most Recent');
                  widget.viewModel.filterByRecent();
                },
              ),
              SizedBox(width: 8),
              _buildCompactChip(
                label: 'Highest',
                isSelected: widget.currentSortOption == 'Highest Score',
                icon: Icons.trending_up,
                onTap: () {
                  widget.onSortChanged('Highest Score');
                  widget.viewModel.filterByHighestScore();
                },
              ),
              SizedBox(width: 8),
              _buildCompactChip(
                label: 'Lowest',
                isSelected: widget.currentSortOption == 'Lowest Score',
                icon: Icons.trending_down,
                onTap: () {
                  widget.onSortChanged('Lowest Score');
                  widget.viewModel.filterByLowestScore();
                },
              ),
            ],
          ),
          
          SizedBox(height: 10),
          
          // Game mode filter
          Text(
            'Game Mode',
            style: TextStyle(
              color: CustomColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          // Game mode options in a row
          Row(
            children: [
              _buildCompactChip(
                label: 'All',
                isSelected: widget.currentGameModeFilter == 'All',
                onTap: () {
                  widget.onGameModeChanged('All');
                  widget.viewModel.filterByGameMode('All');
                },
              ),
              SizedBox(width: 8),
              _buildCompactChip(
                label: 'Time',
                isSelected: widget.currentGameModeFilter == 'Time',
                onTap: () {
                  widget.onGameModeChanged('Time');
                  widget.viewModel.filterByGameMode('Time');
                },
              ),
              SizedBox(width: 8),
              _buildCompactChip(
                label: 'Points',
                isSelected: widget.currentGameModeFilter == 'Points',
                onTap: () {
                  widget.onGameModeChanged('Points');
                  widget.viewModel.filterByGameMode('Points');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // More compact chip design
  Widget _buildCompactChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.mainButton : CustomColors.mainButton.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white30 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: CustomColors.textPrimary,
              ),
              SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: CustomColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small button with icon and label
  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: CustomColors.mainButton.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: CustomColors.textPrimary,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: CustomColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}