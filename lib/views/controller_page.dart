import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/views/game_over_page.dart';
import 'package:laser_car_battle/widgets/buttons/fire_button.dart';
import 'package:laser_car_battle/widgets/buttons/brake_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_joystick.dart';
import 'package:laser_car_battle/widgets/score_board.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';

class RemoteController extends StatefulWidget {
  const RemoteController({super.key});

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up game over callback
      final gameViewModel = Provider.of<GameViewModel>(context, listen: false);
      gameViewModel.onGameOver = () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GameOverPage(),
          ),
        );
      };
      
      gameViewModel.startGame();
    });
    
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
    return Consumer<CarControllerViewModel>(
      builder: (context, controller, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Settings Indicator
              Positioned(
                top: AppSizes.paddingLarge,
                left: AppSizes.paddingMedium,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    //color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: IconButton(
                    icon:  Icon(
                      Icons.settings_sharp,
                      size: AppSizes.iconSize,
                    ),
                    onPressed: () {
                      // Handle settings button press
                      print('Settings pressed');
                    },
                  ),
                ),
              ),
              // Insights widget
              Positioned(
                top: AppSizes.paddingLarge,
                right: AppSizes.paddingMedium,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    //color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(child: Text('')),
                ),
              ),
              // Top Center Widget
              Positioned(
                top: AppSizes.paddingLarge,
                left: 0,
                right: 0,
                child: ScoreBoard(),
              ),

              // Bottom Left Widget
              Positioned(
                bottom: AppSizes.paddingLarge + 10,
                left: AppSizes.paddingLarge + 10,
                child: Row(
                  children: [
                    // Brake control widget
                    BrakeButton(
                      onPressed: () {
                        controller.setBrakeState(true);
                      },
                      onReleased: () {
                        controller.setBrakeState(false);
                      },
                      width: 100,
                      height: 150,
                    ),
                    // Fire button control widget
                    Padding(
                      padding: EdgeInsets.only(left: AppSizes.paddingLarge),
                      child: FireButton(
                        onPressed: () {
                          controller.fire();
                          
                        },
                        size: 150,
                      ),
                    ),
                  ],
                ),
              ),

              // Joystick Widget
              Positioned(
                bottom: AppSizes.paddingLarge +10,
                right: AppSizes.paddingLarge +30,
                child: CustomJoystick(
                  listener: (details) {
                    double sensitivityFactor = 0.7;
                    double scaledX = details.x * sensitivityFactor;
                    double scaledY = details.y * sensitivityFactor;
                    controller.updateJoystickPosition(scaledX, scaledY);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
