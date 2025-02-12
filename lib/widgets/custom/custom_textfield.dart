import 'package:flutter/material.dart';
import 'package:laser_car_battle/utils/constants.dart';

class CustomTextfield extends StatefulWidget {
  final String labelText;

  const CustomTextfield({
    super.key,
    required this.labelText,
  });

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  Color _borderColor = Colors.grey;

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
      child: TextField(
        decoration: InputDecoration(
          labelText: widget.labelText,
            helperText: "3-20 charachters, start with a letter.",
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
      ),
    );
  }
}