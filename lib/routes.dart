import 'package:flutter/material.dart';
import 'package:laser_car_battle/views/bluetooth_page.dart';
import 'package:laser_car_battle/views/controller_page.dart';
import 'package:laser_car_battle/views/game_mode_page.dart';
import 'package:laser_car_battle/views/landing_page.dart';
import 'package:laser_car_battle/views/login_page.dart';

Map<String, Widget Function(BuildContext)> get routes => {
      '/': (context) => const LandingPage(),
      '/login': (context) => const LoginPage(),
      '/connect': (context) =>  BTConnectionPage(),
      '/gameMode': (context) => const  GameModePage(),
      'controller': (context) => const RemoteController(),
    };