import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';
import 'dart:math' as math;  // Add this import

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
        // Calculate magnitude of the joystick position
        final magnitude = math.sqrt(details.x * details.x + details.y * details.y);
        
        // Normalize values if magnitude is not zero
        double normalizedX = details.x;
        double normalizedY = details.y;
        if (magnitude > 0) {
          normalizedX = details.x / magnitude;
          normalizedY = details.y / magnitude;
        }

        // Scale values while preserving direction
        final scaledX = (normalizedX * widget.sensitivityFactor)
            .clamp(-1.0, 1.0)
            * (1.0 / widget.sensitivityFactor);
            
        // Invert Y axis and scale
        final scaledY = (-normalizedY * widget.sensitivityFactor)
            .clamp(-1.0, 1.0)
            * (1.0 / widget.sensitivityFactor);
        
        // Round to 3 decimal places
        final roundedX = double.parse(scaledX.toStringAsFixed(3));
        final roundedY = double.parse(scaledY.toStringAsFixed(3));
        
        // Debug print
        // print('Joystick Update:');
        // print('  Raw - X: ${details.x}, Y: ${-details.y}');
        // print('  Normalized - X: $roundedX, Y: $roundedY');
        
        widget.listener(roundedX, roundedY);
      },
    );
  }

  @override
  void dispose() {
    print('CustomJoystick disposed'); // Debug dispose
    super.dispose();
  }
}