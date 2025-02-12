import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/buttons/main_bottom_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/project_title.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220),
        child: CustomAppBar(
          titleText: "Laser Car Battle",
          borderRadius: 0,
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, // Start from the end of the app bar
            left: 0,
            right: 0,
            height: 400, // Set the desired height of the red box
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(83, 79, 0, 0),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(25), // Add bottom border radius
                ),
              ),
            ),
          ),
            Positioned(
            top: 100, 
            left: 0,
            right: 0,
            child: Center(
              child: TitleText(),
            ),
            ),
          MainBottomButton(buttonText: "Enter Your Name"),
        ],
      ),
    );
  }
}
