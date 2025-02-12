import 'package:flutter/material.dart';
import 'package:laser_car_battle/views/landing_page.dart';
import 'package:laser_car_battle/views/login_page.dart';

Map<String, Widget Function(BuildContext)> get routes => {
      '/': (context) => const LandingPage(),
      '/login': (context) => const LoginPage(),
    };