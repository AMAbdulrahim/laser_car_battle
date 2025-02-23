import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart' ;
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';


class CustomJoystick extends StatelessWidget {
  const CustomJoystick({
    super.key, required Null Function(dynamic details) listener,
  });

  @override
  Widget build(BuildContext context) {
    return Joystick(
        stick: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColors.joystickKnob,
          boxShadow: [
          BoxShadow(
            color: CustomColors.effectColor,
            blurRadius: 3,
            spreadRadius: 1,
          ),
          ],
        ),
        width: AppSizes.joystickKnobSize,
        height: AppSizes.joystickKnobSize,
        ),
        base: Container(
        decoration: BoxDecoration(    
          color: CustomColors.joystickBase.withOpacity(.6),
          shape: BoxShape.circle,
          boxShadow: [
          BoxShadow(
            color: CustomColors.effectColor,
            blurRadius: 3,
            spreadRadius: 0.6,
          ),
          ],
        ),
        width: AppSizes.joystickBaseSize,
        height: AppSizes.joystickBaseSize,
        ),
        
    mode: JoystickMode.all,
    listener: (details) {
      double sensitivityFactor = 0.7; 
      String scaledX = (details.x * sensitivityFactor).toStringAsFixed(2);
      String scaledY = (details.y * sensitivityFactor).toStringAsFixed(2);
      print('Joystick: $scaledX, $scaledY');
    },
                );
  }
}