import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String buttonText;

  const MainButton({
    super.key,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 60, // Set the height of the button
        child: ElevatedButton(
          onPressed: () {
            // Add your onPressed code here!
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
}

