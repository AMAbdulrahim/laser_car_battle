import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class CustomJoystick extends StatefulWidget {
  final Function(double x, double y) listener;
  final double sensitivityFactor;

  const CustomJoystick({
    Key? key,
    required this.listener,
    this.sensitivityFactor = 0.75,
  }) : super(key: key);

  @override
  State<CustomJoystick> createState() => _CustomJoystickState();
}

class _CustomJoystickState extends State<CustomJoystick> {
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
      period: const Duration(milliseconds: 100),
      listener: (details) {
        // Scale and round the values
        final scaledX = (details.x * widget.sensitivityFactor)
            .clamp(-1.0, 1.0);
        final scaledY = (details.y * widget.sensitivityFactor)
            .clamp(-1.0, 1.0);
        
        // Debug print
        print('Joystick Update:');
        print('  Raw - X: ${details.x}, Y: ${details.y}');
        print('  Scaled - X: ${scaledX.toStringAsFixed(2)}, Y: ${scaledY.toStringAsFixed(2)}');
        
        // Pass scaled values directly to listener
        widget.listener(scaledX, scaledY);
      },
    );
  }

  @override
  void dispose() {
    print('CustomJoystick disposed'); // Debug dispose
    super.dispose();
  }
}