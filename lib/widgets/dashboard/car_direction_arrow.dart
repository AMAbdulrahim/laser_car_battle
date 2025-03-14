import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';

/// A widget that displays the car's direction and speed.
/// 
/// The arrow indicates the direction (forward or backward) and the speed
/// percentage. The steering angle is also displayed as a percentage.
class CarDirectionArrow extends StatelessWidget {
  final double speed;      // Speed value between -1.0 and 1.0
  final double angle;      // Steering angle between -1.0 (left) and 1.0 (right)
  
  const CarDirectionArrow({
    super.key,
    required this.speed,
    required this.angle,
  });
  
  @override
  Widget build(BuildContext context) {
    // Get display values
    final bool isMoving = speed.abs() > 0.01; // Check if car is actually moving
    final bool isForward = speed >= 0;
    final int speedPercent = (speed.abs() * 100).round();
    final int anglePercent = (angle.abs() * 100).round();
    
    // Calculate rotation angle (convert from -1...1 to -45°...45°)
    final double rotationAngle = angle * (math.pi / 4); // 45 degrees max rotation
    
    // Determine colors based on direction and movement
    final Color arrowColor = !isMoving ? Colors.white : (isForward ? Colors.green : Colors.red);
    final Color steeringColor = angle == 0 ? Colors.white : 
                              (angle < 0 ? Colors.red : Colors.green);
    
    return Container(
      width: 160,
      height: 180,
      padding: EdgeInsets.all(15),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Car direction arrow
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Center(
              child: Transform.rotate(
                angle: rotationAngle,
                child: Icon(
                  isForward ? Icons.arrow_upward : Icons.arrow_downward,
                  color: arrowColor,
                  size: 50,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 10),
          
          // Speed and direction percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 55,
                child: Column(
                  children: [
                    Text(
                      'SPEED',
                      style: TextStyle(
                        color: Colors.white, // Fixed missing color
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      speed == 0 ? '0%' : 
                      '${speed < 0 ? "-" : "+"}$speedPercent%',
                      style: TextStyle(
                        color: arrowColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Added center alignment
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: 15),
              
              SizedBox(
                width: 55,
                child: Column(
                  children: [
                    Text(
                      'STEER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      angle == 0 ? '0%' : 
                      '${angle < 0 ? "-" : "+"}$anglePercent%',
                      style: TextStyle(
                        color: steeringColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Added center alignment
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}