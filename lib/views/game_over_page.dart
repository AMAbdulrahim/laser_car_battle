import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

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

  void _shareResults(GameViewModel gameViewModel) {
    final String result = gameViewModel.winner == 'Draw'
        ? 'Game ended in a Draw!'
        : '${gameViewModel.winner} Won!';
    
    final String timeInfo = gameViewModel.gameMode == 'Points'
        ? '\nTime Elapsed: ${gameViewModel.formattedTime}'
        : '';
    
    final String message = '''
🎮 Laser Car Battle Results 🚗
$result
Final Score: ${gameViewModel.player1Points} - ${gameViewModel.player2Points}
Game Mode: ${gameViewModel.gameMode}$timeInfo
''';

    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(  // Changed from WillPopScope to PopScope
      canPop: false,  // Prevent back navigation
      child: Scaffold(
        body: Stack(
          children: [
            // Main content centered
            Center(
              child: Container(
                padding: const EdgeInsets.only(
                  top: AppSizes.paddingLarge * 2, // Extra padding for share button
                  left: AppSizes.paddingLarge,
                  right: AppSizes.paddingLarge,
                  bottom: AppSizes.paddingLarge,
                ),
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
                        if (gameViewModel.gameMode == 'Points') ...[
                          const SizedBox(height: 20),
                          Text(
                            'Time Elapsed',
                            style: TextStyle(
                              fontSize: 24,
                              color: CustomColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            gameViewModel.formattedTime,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: CustomColors.textPrimary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(  // Wrap button with Material
                              color: Colors.transparent,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomColors.mainButton,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (Route<dynamic> route) => false,
                                ),
                                child: Text(
                                  'Back to Menu',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: CustomColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Share button on top
            Positioned(
              top: AppSizes.paddingLarge,
              right: AppSizes.paddingMedium,
              child: Consumer<GameViewModel>(
                builder: (context, gameViewModel, child) {
                  return Material(  // Wrap IconButton with Material
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: CustomColors.textPrimary,
                        size: 32,
                      ),
                      onPressed: () => _shareResults(gameViewModel),
                      style: IconButton.styleFrom(
                        backgroundColor: CustomColors.mainButton,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}