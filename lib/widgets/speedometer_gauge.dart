import 'package:flutter/material.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'dart:math' as math;

class SpeedometerGauge extends StatelessWidget {
  final double speed; // Speed value between -1.0 and 1.0
  final double maxSpeed; // Current max speed setting (0.1 to 1.0)
  
  const SpeedometerGauge({
    super.key,
    required this.speed,
    required this.maxSpeed,
  });
  
  @override
  Widget build(BuildContext context) {
    // Normalize speed for display (absolute value for gauge, sign for direction)
    final double absSpeed = speed.abs();
    
    
    
    // Calculate color based on speed
    Color gaugeColor = CustomColors.joystickBase;
    if (absSpeed > 0.8) {
      gaugeColor = Colors.red;
    } else if (absSpeed > 0.5) {
      gaugeColor = Colors.orange;
    } else if (absSpeed > 0.2) {
      gaugeColor = Colors.yellow;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center, // Ensure center alignment horizontally
      children: [
        // Speed gauge (semi-circular) - completely flipped to show upper semi-circle
        Container(
          width: 200,
          height: 30,
          margin: EdgeInsets.only(top: 10), // Add top margin to push it down
          // Position the gauge at the bottom of its container
          alignment: Alignment.bottomCenter,
          // Apply a vertical flip transform to the gauge
          transform: Matrix4.identity()..scale(1.0, -1.0),
          transformAlignment: Alignment.bottomCenter, // Change to bottom center
          child: CustomPaint(
            size: Size(80, 60),
            painter: SpeedometerPainter(
              speed: absSpeed,
              maxSpeed: maxSpeed,
              gaugeColor: gaugeColor,
            ),
          ),
        ),
        
        // const SizedBox(width: 10),
  
        // Direction indicator and speed percentage
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.end, // Center vertically
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     // Direction arrow
        //     Icon(
        //       isForward ? Icons.arrow_upward : Icons.arrow_downward,
        //       color: isForward ? Colors.green : Colors.red,
        //       size: 30,
        //     ),
            
        //     // Speed percentage text
        //     Text(
        //       '$speedPercent%',
        //       style: TextStyle(
        //         fontSize: 16,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;
  final Color gaugeColor;
  
  SpeedometerPainter({
    required this.speed,
    required this.maxSpeed,
    required this.gaugeColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Still set center at the bottom middle, it will be flipped by the transform above
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    
    // Draw background arc (gray)
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      math.pi, // Start at left (pi radians)
      -math.pi, // Go counter-clockwise to right (-pi radians)
      false,
      bgPaint,
    );
    
    // Draw filled arc based on speed value
    final speedPaint = Paint()
      ..color = gaugeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    // Calculate angle based on speed and max speed - counterclockwise
    final fillRatio = speed / maxSpeed;
    final sweepAngle = -math.pi * fillRatio.clamp(0.0, 1.0);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      math.pi, // Start at left
      sweepAngle, // Go counter-clockwise based on speed
      false,
      speedPaint,
    );
    
    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i <= 10; i++) {
      final tickAngle = math.pi - (i * math.pi / 10);  // Start at left, go counter-clockwise
      final outerPoint = Offset(
        center.dx + (radius - 2) * math.cos(tickAngle),
        center.dy + (radius - 2) * math.sin(tickAngle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 10) * math.cos(tickAngle),
        center.dy + (radius - 10) * math.sin(tickAngle),
      );
      
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
    
    // Draw current speed indicator (needle)
    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final needleAngle = math.pi - (fillRatio.clamp(0.0, 1.0) * math.pi);
    final needlePoint = Offset(
      center.dx + (radius - 15) * math.cos(needleAngle),
      center.dy + (radius - 15) * math.sin(needleAngle),
    );
    
    canvas.drawLine(center, needlePoint, needlePaint);
    
    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 5, centerPaint);
  }
  
  @override
  bool shouldRepaint(SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed || 
           oldDelegate.maxSpeed != maxSpeed ||
           oldDelegate.gaugeColor != gaugeColor;
  }
}