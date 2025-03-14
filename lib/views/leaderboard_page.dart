import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/leaderboard_viewmodel.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/leaderboard/leaderboard_filter_panel.dart';
import 'package:laser_car_battle/widgets/leaderboard/leaderboard_entries_list.dart'; 
import 'package:provider/provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  String _currentSortOption = 'Most Recent';
  String _currentGameModeFilter = 'All';
  bool _showFilterPanel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: CustomAppBar(
          titleText: "Leaderboard",
          actionIcon: Icons.filter_list,
          actionTooltip: "Show/Hide Filters",
          onActionPressed: () {
            setState(() {
              _showFilterPanel = !_showFilterPanel;
            });
          },
        ),
      ),
      body: Consumer<LeaderboardViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: AppSizes.iconSize, color: CustomColors.textPrimary),
                  SizedBox(height: 16),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          }

          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Text(
                'Failed to load leaderboard',
              ),
            );
          }

          return Column(
            children: [
              // Filter panel that slides in/out with adjusted height
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _showFilterPanel ? 160 : 0,
                curve: Curves.easeInOut,
                child: Stack(
                  children: [
                    Container(color: CustomColors.background),
                    ClipRect(
                      child: OverflowBox(
                        maxHeight: 160,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: 160,
                          child: LeaderboardFilterPanel(
                            viewModel: viewModel,
                            currentSortOption: _currentSortOption,
                            currentGameModeFilter: _currentGameModeFilter,
                            onSortChanged: (newSort) {
                              setState(() => _currentSortOption = newSort);
                            },
                            onGameModeChanged: (newMode) {
                              setState(() => _currentGameModeFilter = newMode);
                            },
                            onResetFilters: () {
                              setState(() {
                                _currentSortOption = 'Most Recent';
                                _currentGameModeFilter = 'All';
                              });
                              viewModel.resetFilters();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Leaderboard entries
              Expanded(
                child: LeaderboardEntriesList(
                  entries: viewModel.entries,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}