import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/settings_dropdown.dart';
import 'package:laser_car_battle/widgets/insights/insights.dart';
import 'package:laser_car_battle/widgets/score/score_board.dart';
import 'package:provider/provider.dart';

class ControllerHeader extends StatelessWidget {
  final Function() onToggleControls;
  final Function() onToggleDebug;
  final Function() onToggleControlType;
  final Function() onToggleVisualMode;

  const ControllerHeader({
    super.key,
    required this.onToggleControls,
    required this.onToggleDebug,
    required this.onToggleControlType,
    required this.onToggleVisualMode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Settings dropdown
        Positioned(
          top: AppSizes.paddingLarge,
          left: AppSizes.paddingMedium,
          child: SettingsDropdown(
            onToggleControls: onToggleControls,
            onToggleDebug: onToggleDebug,
            onToggleControlType: onToggleControlType,
            onToggleVisualMode: onToggleVisualMode,
          ),
        ),
        
        // Game insights
        Positioned(
          top: AppSizes.paddingLarge,
          right: AppSizes.paddingMedium,
          child: Consumer<GameViewModel>(
            builder: (context, gameViewModel, _) {
              return Insights(
                gameCode: gameViewModel.gameCode,
              );
            },
          ),
        ),
        
        // Score board
        Positioned(
          top: AppSizes.paddingLarge,
          left: 0,
          right: 0,
          child: ScoreBoard(),
        ),
      ],
    );
  }
}