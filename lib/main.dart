import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/custom_theme.dart';
import 'package:laser_car_battle/providers/providers.dart';
import 'package:laser_car_battle/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: CustomTheme.darkTheme,
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}

