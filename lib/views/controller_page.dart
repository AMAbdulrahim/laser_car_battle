import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/views/game_over_page.dart';
import 'package:laser_car_battle/widgets/buttons/fire_button.dart';
import 'package:laser_car_battle/widgets/buttons/brake_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_joystick.dart';
import 'package:laser_car_battle/widgets/insights.dart';
import 'package:laser_car_battle/widgets/score_board.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/car_controller_viewmodel.dart';
import 'package:laser_car_battle/viewmodels/game_viewmodel.dart';
import 'package:laser_car_battle/widgets/buttons/settings_dropdown.dart';

class RemoteController extends StatefulWidget {
  const RemoteController({super.key});

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
  // Add state variable for control position
  bool _controlsOnLeft = true;

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
              // Settings Popup Menu widget
              Positioned(
                top: AppSizes.paddingLarge,
                left: AppSizes.paddingMedium,
                child: SettingsDropdown(
                  onToggleControls: () {
                    setState(() {
                      _controlsOnLeft = !_controlsOnLeft;
                    });
                  },
                ),
              ),
              // Insights widget
              Positioned(
                top: AppSizes.paddingLarge,
                right: AppSizes.paddingMedium,
                child: Insights(),
              ),
              // Score Board Widget
              Positioned(
                top: AppSizes.paddingLarge,
                left: 0,
                right: 0,
                child: ScoreBoard(),
              ),
              //  Brake & Fire Controls Widget
              Positioned(
                bottom: AppSizes.paddingLarge + 10,
                left: _controlsOnLeft ? AppSizes.paddingLarge + 10 : null,
                right: _controlsOnLeft ? null : AppSizes.paddingLarge + 10,
                child: Row(
                  children: _controlsOnLeft 
                  ? [
                      // Left side controls
                      BrakeButton(
                        onPressed: () => controller.setBrakeState(true),
                        onReleased: () => controller.setBrakeState(false),
                        width: 100,
                        height: 150,
                        isRightBrake: false,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: AppSizes.paddingLarge),
                        child: FireButton(
                          onPressed: () => controller.fire(),
                          size: 150,
                        ),
                      ),
                    ]
                  : [
                      // Right side controls
                      FireButton(
                        onPressed: () => controller.fire(),
                        size: 150,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: AppSizes.paddingLarge),
                        child: BrakeButton(
                          onPressed: () => controller.setBrakeState(true),
                          onReleased: () => controller.setBrakeState(false),
                          width: 100,
                          height: 150,
                          isRightBrake: true,
                        ),
                      ),
                    ],
                ),
              ),
              // Joystick Widget
              Positioned(
                bottom: AppSizes.paddingLarge +10,
                left: _controlsOnLeft ? null : AppSizes.paddingLarge +30,
                right: _controlsOnLeft ? AppSizes.paddingLarge +30 : null,
                child: CustomJoystick(
                  listener: (details) {
                    double sensitivityFactor = 0.75;
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
