import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/buttons/main_button.dart';
import 'package:laser_car_battle/widgets/custom/custom_textfield.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextfield(
            labelText: "Name",
          ),
          MainButton(
            buttonText: 'Login',
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).popAndPushNamed('/');
              }
            },
          ),
        ],
      ),
    );
  }
}
