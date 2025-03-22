import 'package:flutter/material.dart';
import 'package:laser_car_battle/widgets/dashboard/car_dashboard.dart';
import 'package:laser_car_battle/widgets/dashboard/car_direction_arrow.dart';

class DashboardDisplay extends StatelessWidget {
  final double speed;
  final double angle;
  final double maxSpeed;
  final bool useVisualIndicator;

  const DashboardDisplay({
    super.key,
    required this.speed,
    required this.angle,
    required this.maxSpeed,
    required this.useVisualIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: useVisualIndicator
          ? CarDirectionArrow(
              speed: speed,
              angle: angle,
            )
          : CarDashboard(
              speed: speed,
              angle: angle,
              maxSpeed: maxSpeed,
            ),
    );
  }
}