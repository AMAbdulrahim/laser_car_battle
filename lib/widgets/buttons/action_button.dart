import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  final VoidCallback onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(AppSizes.actionButtonWidth, AppSizes.actionButtonHeight), 
        //backgroundColor: CustomColors.actionButton, 
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: AppSizes.fontLarge,
          color: CustomColors.textPrimary,
          letterSpacing: 1.5, 
        ),
      ),
    );
  }
}
