import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GameOverPage extends StatefulWidget {
  const GameOverPage({super.key});

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  final GlobalKey _statsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Make sure game is fully ended
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
      
      // Ensure timers are cancelled
      if (gameViewModel.winner != null) {
        // Force a final end game check to ensure timers are stopped
        gameViewModel.gameOver();
      }
    });
  }

  @override
  void dispose() {
    // No need to reset orientation in dispose since we're already in portrait
    super.dispose();
  }

  Future<void> _shareResultsAsImage() async {
    try {
      // Capture the stats widget as an image
      RenderRepaintBoundary boundary = _statsKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        File file = File('${tempDir.path}/game_stats.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());
        
        // Share the image
        await Share.shareXFiles(
          [XFile(file.path)],
            text: '🎮 Laser Car Battle Results 🚗\n\nTeam 57 project - check it out!',
        );
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
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
                        // Wrap stats in RepaintBoundary for image capture
                        RepaintBoundary(
                          key: _statsKey,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: CustomColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                    gameViewModel.formattedFinalTime,  // Use this instead of formattedTime
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
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
                      onPressed: _shareResultsAsImage,
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