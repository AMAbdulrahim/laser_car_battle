import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/buttons/main_bottom_button.dart';
import 'package:laser_car_battle/widgets/project_title.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: TitleText(),
          ),
          MainBottomButton(buttonText: "Enter Your Name"),
        ],
      ),
    );
  }
}
