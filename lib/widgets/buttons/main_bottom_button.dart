import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/buttons/main_button.dart';

class MainBottomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;

  const MainBottomButton({
    super.key,
    required this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        MainButton(
          buttonText: buttonText,
          onPressed: onPressed,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
