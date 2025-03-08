import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';

class MainButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final BorderSide? border;
  final double? borderRadius;

  const MainButton({
    super.key,
    required this.buttonText,
    this.onPressed,
    this.backgroundColor,
    this.border,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: SizedBox(
        width: double.infinity,
        height: AppSizes.buttonHeight, // Set the height of the button
        child: ElevatedButton(
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            side: border,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius!),
              side: border ?? BorderSide.none,
            ),
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }
}

