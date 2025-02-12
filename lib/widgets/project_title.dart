import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Team',
          style: TextStyle(
            fontSize: AppSizes.fontTitle,
          ),
        ),
        Text(
          '57',
          style: TextStyle(
            fontSize: AppSizes.fontTitle,
          ),
        ),
      ],
    );
  }
}