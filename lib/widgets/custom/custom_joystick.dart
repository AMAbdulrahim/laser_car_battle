import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class CustomJoystick extends StatefulWidget {
  final Function(double x, double y) listener;
  final double sensitivityFactor;

  const CustomJoystick({
    super.key,
    required this.listener,
    this.sensitivityFactor = 1,
  });

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
        // Direct mapping of joystick position to control values
        // X: controls steering (-1.0 to 1.0)
        // Y: controls speed (-1.0 to 1.0), inverted so up is positive
        
        // Apply sensitivity curve to make small adjustments easier
        double steeringValue = details.x * widget.sensitivityFactor;
        // Invert Y so pushing up means forward
        double speedValue = -details.y * widget.sensitivityFactor;
        
        // Optional: Apply non-linear response for more precise control around center
        // This gives finer control for small movements
        steeringValue = applyControlCurve(steeringValue);
        speedValue = applyControlCurve(speedValue);
        
        // Clamp values between -1.0 and 1.0
        steeringValue = steeringValue.clamp(-1.0, 1.0);
        speedValue = speedValue.clamp(-1.0, 1.0);
        
        // Round to 3 decimal places for cleaner values
        final roundedX = double.parse(steeringValue.toStringAsFixed(3));
        final roundedY = double.parse(speedValue.toStringAsFixed(3));
        
        // Send the values to the listener
        widget.listener(roundedX, roundedY);
      },
    );
  }

  // Helper method for applying a control curve
  double applyControlCurve(double input) {
    // Apply a cubic curve for more precision in the middle
    // This gives more fine-grained control for small movements
    return input * input * input;
  }

  @override
  void dispose() {
    print('CustomJoystick disposed'); // Debug dispose
    super.dispose();
  }
}