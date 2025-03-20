import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

class Insights extends StatelessWidget {
  final String gameCode;
  
  const Insights({
    super.key, 
    required this.gameCode,
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game mode and value (existing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${gameViewModel.gameMode}: $targetText',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Only show game code when it's not empty
              if (gameCode.isNotEmpty) ...[
                SizedBox(height: 4), // Small spacing between rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      gameCode,
                      style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.actionButton,
                      letterSpacing: 1.5, 
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
