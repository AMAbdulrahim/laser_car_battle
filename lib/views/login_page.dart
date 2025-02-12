import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/custom/custom_app_bar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220),
        child: CustomAppBar(
          titleText: "Laser Car Battle",
          borderRadius: 0,
        
      ),
      ),
      body: Center(
        child: Text('Welcome to the Login Page'),
      ),
    );
  }
}