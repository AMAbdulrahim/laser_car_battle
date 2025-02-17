import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/buttons/fire_button.dart';
import 'package:laser_car_battle/widgets/buttons/brake_button.dart';

class RemoteController extends StatefulWidget {
  const RemoteController({super.key});

  @override
  State<RemoteController> createState() => _RemoteControllerState();
}

class _RemoteControllerState extends State<RemoteController> {
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
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(child: Text('settings')),
            ),
          ),
          // insights widget
          Positioned(
            top: AppSizes.paddingLarge,
            right: AppSizes.paddingMedium,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(child: Text('insights')),
            ),
          ),
          // Top Center Widget
          Positioned(
            top: AppSizes.paddingLarge,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.topCenter,
              child: Container(
                width: 600,
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Player 1 name section section
                    Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('Player 1')),
                    ),
                    // Middle section
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // points section
                          Container(
                            height: 70,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('Points')),
                          ),
                          // Timer section
                          Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('Timer')),
                          ),
                        ],
                      ),
                    ),
                    // Player 2 name section
                    Container(
                      width: 200,
                      height: 60,

                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('Player 2')),
                    ),
                  ],
                ),
              ),
            ),
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
                    print('Brake pressed!');
                  },
                  width: 100,
                  height: 150,
                ),
                // Fire button control widget
                Padding(
                  padding: EdgeInsets.only(left: AppSizes.paddingLarge),
                  child: FireButton(
                    onPressed: () {
                      // Handle fire action
                      print('Fire!');
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
            right: AppSizes.paddingLarge + 20,
            child: Container(
              width: 175,
              height: 175,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('Joystick')),
            ),
          ),
        ],
      ),
    );
  }
}