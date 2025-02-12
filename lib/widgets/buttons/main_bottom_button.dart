import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/buttons/main_button.dart';

class MainBottomButton extends StatelessWidget {
  final String buttonText;

  const MainBottomButton({
    super.key,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        MainButton(buttonText: buttonText),
        SizedBox(height: 20),
      ],
    );
  }
}
