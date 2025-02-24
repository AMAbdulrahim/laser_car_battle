import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

class Insights extends StatelessWidget {
  const Insights({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,  // Reduced width
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColors.border),
        borderRadius: BorderRadius.circular(5),
        color: CustomColors.mainButton.withOpacity(0.8),
      ),
      child: Consumer<GameViewModel>(
        builder: (context, gameViewModel, child) {
          String targetText = gameViewModel.gameMode == 'Time' 
              ? '${gameViewModel.gameValue}m' 
              : '${gameViewModel.targetPoints}p';
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${gameViewModel.gameMode}: $targetText',
                style: TextStyle(
                  fontSize: 14,
                  color: CustomColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
