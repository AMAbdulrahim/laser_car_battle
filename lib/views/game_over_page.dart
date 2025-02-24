import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';

class GameOverPage extends StatefulWidget {
  const GameOverPage({super.key});

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Row(  // Changed from Column to Row
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Consumer<GameViewModel>(
                  builder: (context, gameViewModel, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Game Over!',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          gameViewModel.winner == 'Draw'
                              ? 'It\'s a Draw!'
                              : '${gameViewModel.winner} Wins!',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Final Score',
                          style: TextStyle(
                            fontSize: 24,
                            color: CustomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${gameViewModel.player1Points} - ${gameViewModel.player2Points}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.mainButton,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                          ),
                          onPressed: () {
                            Provider.of<GameViewModel>(context, listen: false)
                                .clearGameSettings();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/',
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Text(
                            'Back to Menu',
                            style: TextStyle(
                              fontSize: 24,
                              color: CustomColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}