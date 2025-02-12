import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class CustomTextfield extends StatefulWidget {
  final String labelText;

  const CustomTextfield({
    super.key,
    required this.labelText,
  });

  @override
  CustomTextfieldState createState() => CustomTextfieldState();
}

class CustomTextfieldState extends State<CustomTextfield> {
  Color _borderColor = CustomColors.border;

  void _validateInput(String value) {
    final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{2,19}$');
    setState(() {
      if (!regex.hasMatch(value)) {
        _borderColor = Colors.red;
      } else {
        _borderColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: widget.labelText,
          helperText: "3-20 characters, start with a letter.",
          border: OutlineInputBorder(
            borderSide: BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _borderColor),
          ),
        ),
        onChanged: _validateInput,
        validator: (value) {
          final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9]{2,19}$');
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          } else if (!regex.hasMatch(value)) {
            return 'Please enter a valid input (3-20 characters, start with a letter, letters and numbers only)';
          }
          return null;
        },
      ),
    );
  }
}