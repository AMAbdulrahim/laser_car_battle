import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

import 'package:laser_car_battle/widgets/dashboard/speedometer_gauge.dart';
import 'package:laser_car_battle/widgets/dashboard/steering_indicator.dart';

class CarDashboard extends StatelessWidget {       
  final double speed;      // Speed value between -1.0 and 1.0
  final double angle;      // Steering angle between -1.0 (left) and 1.0 (right)
  final double maxSpeed;   // Current max speed setting (0.1 to 1.0)
  
  const CarDashboard({
    super.key,
    required this.speed,
    required this.angle,
    required this.maxSpeed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSmall, horizontal: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: CustomColors.mainButton.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CustomColors.border),
        boxShadow: [
          BoxShadow(
            color: CustomColors.effectColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpeedometerGauge(
            speed: speed, 
            maxSpeed: maxSpeed
          ),
          SizedBox(height: AppSizes.paddingLarge),
          SteeringIndicator(
            angle: angle
          )
        ],
      ),
    );
  }
}
