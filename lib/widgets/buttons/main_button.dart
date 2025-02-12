import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';

class MainButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const MainButton({
    super.key,
    required this.buttonText,
    this.onPressed,
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
          
          child: Text(buttonText),
        ),
      ),
    );
  }
}

