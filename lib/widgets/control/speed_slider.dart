import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

/// A vertical slider widget for controlling the car's speed.
/// 
/// The slider displays the current speed percentage and allows the user to
/// adjust the speed within a specified range.
class SpeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double width;
  final double height;
  final bool isRightSide;

  const SpeedSlider({
    required this.value,
    required this.onChanged,
    this.width = 80,            
    this.height = 180,
    this.isRightSide = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CustomColors.joystickKnob.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add percentage indicator at top
          Text(
            "${(value * 100).toInt()}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          // Rotated slider with longer track
          Expanded(
            child: RotatedBox(
              quarterTurns: 3, // Keep at 270° rotation
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 12.0,
                  activeTrackColor: CustomColors.actionButton,
                  inactiveTrackColor: CustomColors.joystickBase,
                  thumbColor: CustomColors.joystickKnob,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
                  // Use custom track shape to maximize length
                  trackShape: CustomTrackShape(),
                ),
                child: Slider(
                  value: value,
                  min: 0.2,
                  max: 1.0,
                  divisions: 8,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Add speed label
          Text(
            "SPEED",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom track shape to maximize slider length.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 8;
    final double trackLeft = offset.dx + 10; // Add padding
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 20; // Subtract padding
    
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
