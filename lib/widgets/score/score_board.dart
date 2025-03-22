import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, gameViewModel, child) {
        return Container(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 600,
            height: 120,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Player 1 name section
                    Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: CustomColors.mainButton,
                        border: Border.all(
                          color: CustomColors.border,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10),)
                      ),
                      child: Center(
                        child: Text(
                          gameViewModel.player1Name.isNotEmpty 
                              ? gameViewModel.player1Name 
                              : 'Player 1',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Middle section
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColors.border,
                          width: 1,
                        ),
                        color: CustomColors.mainButton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // points section
                          Container(
                            height: 68,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                              bottom: BorderSide(
                                color: CustomColors.border,
                                width: 1,
                              ),
                              ),
                              borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${gameViewModel.player1Points}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      '-',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: CustomColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${gameViewModel.player2Points}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Timer section
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                              top: BorderSide(
                                color: CustomColors.border,
                                width: 1,
                              ),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                gameViewModel.formattedTime,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: gameViewModel.timerColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Player 2 name section
                    Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                        color: CustomColors.border,
                        width: 1,
                      ),
                      color: CustomColors.mainButton,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                    ),
                    child: Center(
                      child: Text(
                        gameViewModel.player2Name.isNotEmpty 
                            ? gameViewModel.player2Name 
                            : 'Player 2',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

}