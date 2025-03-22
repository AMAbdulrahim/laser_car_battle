import 'package:flutter/material.dart';

class RcCarsAnimation extends StatefulWidget {
  const RcCarsAnimation({super.key});

  @override
  State<RcCarsAnimation> createState() => _RcCarsAnimationState();
}

class _RcCarsAnimationState extends State<RcCarsAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for car movement
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    
    // Animation that moves the car from left to right and back
    _positionAnimation = Tween<double>(
      begin: -0.8,  // Start off-screen on the left
      end: 0.8,     // End off-screen on the right
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate position based on screen width
        final screenWidth = MediaQuery.of(context).size.width;
        final position = screenWidth * ((_positionAnimation.value + 1) / 2);
        
        // Determine whether to flip the car based on direction
        final isMovingLeft = _controller.status == AnimationStatus.reverse;
        
        return SizedBox(
          height: 120*2,
          width: double.infinity,
          child: Stack(
            children: [
              // Car that moves across the screen
              Positioned(
                left: position - 60,  // Center the car at the position
                bottom: 0,
                child: Transform.flip(
                  flipX: isMovingLeft,  // Flip when moving left
                  child: Image.asset(
                    'assets/images/car.gif',
                    width: 120*2.1,
                    height: 80*2.1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}