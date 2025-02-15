import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laser_car_battle/viewmodels/login_viewmodel.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        // Add more providers here as needed
      ],
      child: child,
    );
  }
}
