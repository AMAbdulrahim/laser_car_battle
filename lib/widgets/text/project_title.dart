import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class TitleText extends StatelessWidget {
  const TitleText({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              'Team',
              style: TextStyle(
                fontSize: AppSizes.fontTitle,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = CustomColors.effectColor,
                shadows: [
                  Shadow(
                    offset: Offset(-1.5, -1.5),
                    color: CustomColors.effectColor,
                  ),
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    color: CustomColors.effectColor,
                  ),
                ],
              ),
            ),
            // Solid text as fill.
            Text(
              'Team',
              style: TextStyle(
                fontSize: AppSizes.fontTitle,
                shadows: [
                  Shadow(
                    offset: Offset(-1.5, -1.5),
                    color: CustomColors.effectColor,
                  ),
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    color: CustomColors.effectColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        Stack(
          children: <Widget>[
            // Stroked text as border.
            Text(
              '57',
              style: TextStyle(
                fontSize: AppSizes.fontTitle,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = CustomColors.effectColor,
                shadows: [
                  Shadow(
                    offset: Offset(-1.5, -1.5),
                    color: CustomColors.effectColor,
                  ),
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    color: CustomColors.effectColor,
                  ),
                ],
              ),
            ),
            // Solid text as fill.
            Text(
              '57',
              style: TextStyle(
                fontSize: AppSizes.fontTitle,
                shadows: [
                  Shadow(
                    offset: Offset(-1.5, -1.5),
                    color: CustomColors.effectColor,
                  ),
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    color: CustomColors.effectColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}