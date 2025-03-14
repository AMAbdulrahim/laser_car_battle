import 'package:flutter/material.dart';

class SteeringIndicator extends StatelessWidget {
  final double angle; // The steering angle between -1.0 (left) and 1.0 (right)
  final double size; // Size of the widget
  
  const SteeringIndicator({
    super.key,
    required this.angle,
    this.size = 120,
  });
  
  @override
  Widget build(BuildContext context) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left indicator
            Icon(
              Icons.arrow_back,
              color: angle < 0 ? Colors.red : Colors.white30,
              size: 18,
            ),
            
            // Steering gauge - horizontal version
            SizedBox(
              width: 140,  // Fixed width for the gauge
              height: 26,
              child: CustomPaint(
                painter: SteeringPainter(angle: angle),
              ),
            ),
            
            // Right indicator
            Icon(
              Icons.arrow_forward,
              color: angle > 0 ? Colors.green : Colors.white30,
              size: 18,
            ),
          ],
        ),
       
      ],
    );
  }
}

class SteeringPainter extends CustomPainter {
  final double angle; // Between -1.0 (left) and 1.0 (right)
  
  SteeringPainter({required this.angle});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    
    // Draw the horizontal background line
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
      
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(width, center.dy),
      bgPaint
    );
    
    // Draw tick marks
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw 5 tick marks along the line
    for (int i = 0; i <= 4; i++) {
      final tickX = width * i / 4;
      canvas.drawLine(
        Offset(tickX, center.dy - 6),
        Offset(tickX, center.dy + 6),
        tickPaint
      );
    }
    
    // Calculate the position based on steering input (-1 to 1)
    final position = center.dx + (center.dx * angle);
    
    // Draw the steering indicator line
    final steeringPaint = Paint()
      ..color = angle == 0 ? Colors.white : (angle > 0 ? Colors.green : Colors.red)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Draw active portion of the steering bar
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(position, center.dy),
      steeringPaint..strokeWidth = 8..strokeCap = StrokeCap.round
    );
    
    // Draw indicator knob
    final knobPaint = Paint()
      ..color = angle == 0 ? Colors.white : (angle > 0 ? Colors.green : Colors.red)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(position, center.dy), 6, knobPaint);
    canvas.drawCircle(Offset(position, center.dy), 6, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
    );
  }
  
  @override
  bool shouldRepaint(covariant SteeringPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}