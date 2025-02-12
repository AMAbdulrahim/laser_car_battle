import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/custom_theme.dart';
import 'package:laser_car_battle/views/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: CustomTheme.darkTheme,
      home: LandingPage(),
    
    );
  }
}

