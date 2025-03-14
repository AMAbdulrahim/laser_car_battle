import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/widgets/buttons/main_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';
import 'package:laser_car_battle/widgets/text/project_title.dart';

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
      body: SafeArea(
        child: Stack(
          children: [
            // Background red box
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(83, 79, 0, 0),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(25),
                  ),
                ),
              ),
            ),

            // Title text
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: TitleText(),
              ),
            ),

            // Column containing both buttons - FIXED VERSION
            Positioned(
              left: 0,
              right: 0,
              bottom: 20, // Give some space at the bottom
              child: Column(
                mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
                children: [
                  MainButton(
                    backgroundColor: CustomColors.background,
                    border: BorderSide(color: CustomColors.border),
                    buttonText: 'Leaderboard',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/leaderboard'),
                  ),
                  MainButton(
                    buttonText: "Enter Your Name",
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                  ),
                  // Removed the extra SizedBox to prevent overflow
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
