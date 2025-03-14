import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:laser_car_battle/assets/theme/colors/color.dart';
import 'package:laser_car_battle/utils/constants.dart';

class ArrowControls extends StatefulWidget {
  final Function(double x, double y) onControlUpdate;
  final Function(bool) onBrakePressed;
  final double maxSpeed; 
  final bool holdSteering;  // Whether steering holds position when released
  final ValueChanged<bool>? onToggleHoldSteering; // Add this callback
  final bool controlsOnLeft; // Add this parameter

  const ArrowControls({
    required this.onControlUpdate,
    required this.onBrakePressed,
    this.maxSpeed = 1.0, // Default to 1.0 if not provided
    this.holdSteering = false,  // Default to auto-centering
    this.onToggleHoldSteering, // Add callback parameter
    this.controlsOnLeft = true, // Default to left side
    super.key,
  });

  @override
  ArrowControlsState createState() => ArrowControlsState();
}

class ArrowControlsState extends State<ArrowControls> with SingleTickerProviderStateMixin {
  // X (direction) and Y (speed) values
  double x = 0.0;
  double y = 0.0;
  double speedMultiplier = 0.0;
  
  bool isBrakePressed = false;
  
  // constants for control feel
  final double minSpeed = 0.15;
  final double acceleration = 0.02;
  final double deceleration = 0.04;
  final double threshold = 0.02;
  final double sensitivity = 0.02;
  final double epsilon = 0.001;
  
  Map<String, bool> keyPressed = {
    "up": false,
    "down": false,
    "left": false,
    "right": false,
  };

  late Ticker _ticker;
  double _lastX = 0.0;
  double _lastY = 0.0;
  bool _isTickerActive = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (!mounted) return;
      _updateState(elapsed);
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    // Clear any pressed keys
    keyPressed.clear();
    // Send final zero update
    if (mounted) {
      widget.onControlUpdate(0.0, 0.0);
    }
    super.dispose();
  }

  void _startTicker() {
    if (!_isTickerActive) {
      _ticker.start();
      _isTickerActive = true;
    }
  }

  void _stopTicker() {
    if (_isTickerActive) {
      // Only stop if values are effectively zero or if we're not holding steering
      bool shouldStop = !_isAnyKeyPressed() && 
                       (y.abs() < threshold) && 
                       (widget.holdSteering ? true : x.abs() < threshold);
                       
      if (shouldStop) {
        _ticker.stop();
        _isTickerActive = false;
        // Send exact zero for Y, but keep X if holdSteering is true
        if (mounted) {
          y = 0.0;
          _lastY = 0.0;
          
          // Only reset X if we're not holding steering
          if (!widget.holdSteering) {
            x = 0.0;
            _lastX = 0.0;
          }
          
          widget.onControlUpdate(x, y);
        }
      }
    }
  }

  void _updateState(Duration elapsed) {
    if (!mounted) return;
    
    double targetX = 0.0;
    double targetY = 0.0;

    // Handle acceleration multiplier with minimum speed
    if (_isAnyKeyPressed()) {
      speedMultiplier = ((speedMultiplier + acceleration) * (1.0 - minSpeed) + minSpeed)
          .clamp(minSpeed, 1.0);
    } else {
      speedMultiplier = (speedMultiplier - deceleration).clamp(0.0, 1.0);
    }

    // Use widget.maxSpeed instead of constant maxValue or _maxValue
    if (keyPressed["left"] == true) {
      targetX = -1.0; // X value is always full
      targetY = widget.maxSpeed; // Y is scaled by maxSpeed
    } else if (keyPressed["right"] == true) {
      targetX = 1.0; // X value is always full
      targetY = widget.maxSpeed; // Y is scaled by maxSpeed
    } else if (keyPressed["up"] == true) {
      targetY = widget.maxSpeed; // Y is scaled by maxSpeed
    } else if (keyPressed["down"] == true) {
      targetY = -widget.maxSpeed; // Y is scaled by maxSpeed
    }

    // Apply speed multiplier to movement with minimum speed
    if (targetX != 0) {
      // Apply steering when button pressed
      double step = (targetX - x).sign * sensitivity * speedMultiplier;
      
      // Check if we're already at or beyond the target and still pressing in that direction
      if ((targetX > 0 && x >= targetX) || (targetX < 0 && x <= targetX)) {
        // We're already at or beyond maximum in the desired direction
        // Just maintain the current value without decreasing
        x = x;  // This does nothing but makes the logic clear
      }
      else if ((targetX - x).abs() < sensitivity) {
        // Close to target, set exactly to full value (without multiplying by speedMultiplier)
        x = targetX;  // Set to exact target (1.0 or -1.0)
      } 
      else {
        // Not yet at target, continue moving toward it
        x = (x + step).clamp(-1.0, 1.0);
      }
    } else if (!widget.holdSteering) {
      // Auto-center only if holdSteering is false
      if (x.abs() < sensitivity) {
        x = 0;
      } else {
        x -= x.sign * sensitivity;
      }
    }

    // Similar update for Y movement
    if (targetY != 0) {
      double step = (targetY - y).sign * sensitivity * speedMultiplier;
      if ((targetY - y).abs() < sensitivity) {
        y = targetY * speedMultiplier;
      } else {
        y += step;
      }
    } else {
      if (y.abs() < sensitivity) {
        y = 0;
      } else {
        y -= y.sign * sensitivity;
      }
    }

    // Only clamp Y value using maxSpeed
    x = x.clamp(-1.0, 1.0);
    y = y.clamp(-widget.maxSpeed, widget.maxSpeed);

    // Round values to prevent floating point errors
    x = double.parse(x.toStringAsFixed(3));
    y = double.parse(y.toStringAsFixed(3));

    // More aggressive zero snapping
    if (x.abs() < threshold) x = 0.0;
    if (y.abs() < threshold) y = 0.0;

    // Only send updates for significant changes
    if (_isSignificantChange(x, _lastX) || _isSignificantChange(y, _lastY)) {
      _lastX = x;
      _lastY = y;
      widget.onControlUpdate(x, y);
      if (mounted) {
        setState(() {});
      }
    }

    // Check if we can stop the ticker after update
    _stopTicker();
  }

  bool _isAnyKeyPressed() {
    return keyPressed.values.any((pressed) => pressed);
  }

  void _onKeyChange(String key, bool isPressed) {
    if (!mounted) return;
    
    setState(() {
      keyPressed[key] = isPressed;
    });

    // Start ticker when key is pressed
    if (isPressed) {
      _startTicker();
    } else {
      // Check if we should stop the ticker after key release
      _stopTicker();
    }
  }

  bool _isSignificantChange(double a, double b) {
    return (a - b).abs() > epsilon;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main controls column - unchanged
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row - Up arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton("up", Icons.arrow_upward),
              ],
            ),
            
            // Second row - Left, Brake, Right
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _arrowButton("left", Icons.arrow_back),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                  child: _brakeButton(),
                ),
                _arrowButton("right", Icons.arrow_forward),
              ],
            ),
            
            // Third row - Just the down arrow, no lock button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _arrowButton("down", Icons.arrow_downward),
              ],
            ),
          ],
        ),
        
        // The auto-toggle button positioned based on control side
        Positioned(
          bottom: 15,
          left: widget.controlsOnLeft ? 15 : null, // Left position if controls are on left
          right: widget.controlsOnLeft ? null : 15, // Right position if controls are on right
          child: _buildAutoToggleButton(),
        ),
      ],
    );
  }

  // In the _arrowButton method, modify to show a persistent highlight for left/right when steering is held
  Widget _arrowButton(String key, IconData icon) {
    // Check if this is a steering button that should be highlighted when held
    bool isSteeringHeld = widget.holdSteering && 
                         (key == "left" || key == "right") && 
                         ((key == "left" && x < -0.05) || (key == "right" && x > 0.05));
                         
    return GestureDetector(
      onTapDown: (_) => _onKeyChange(key, true),
      onTapUp: (_) => _onKeyChange(key, false),
      onTapCancel: () => _onKeyChange(key, false),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (keyPressed[key] == true || isSteeringHeld) 
                 ? CustomColors.joystickBase 
                 : CustomColors.joystickKnob,
        ),
        child: Icon(
          icon, 
          color: (keyPressed[key] == true || isSteeringHeld) 
                 ? CustomColors.joystickKnob 
                 : CustomColors.joystickBase,
          size: 36,
        ),
      ),
    );
  }

  // Update brake button to be square with text
  Widget _brakeButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isBrakePressed = true);
        widget.onBrakePressed(true);
      },
      onTapUp: (_) {
        setState(() => isBrakePressed = false);
        widget.onBrakePressed(false);
      },
      onTapCancel: () {
        setState(() => isBrakePressed = false);
        widget.onBrakePressed(false);
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,  // Changed to square
          borderRadius: BorderRadius.circular(10), // Slightly rounded corners
          color: !isBrakePressed ? CustomColors.joystickBase : CustomColors.joystickKnob,
        ),
        child: Center(
          child: Text(
            "BRAKE",
            style: TextStyle(
              color: !isBrakePressed ? CustomColors.joystickKnob : CustomColors.joystickBase,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // New method to build the toggle button
  Widget _buildAutoToggleButton() {
    return GestureDetector(
      onTap: () {
        if (widget.onToggleHoldSteering != null) {
          widget.onToggleHoldSteering!(!widget.holdSteering);
        }
      },
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.all(5), // Consistent margin on all sides
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.holdSteering ? 
            CustomColors.joystickBase.withOpacity(0.8) : 
            CustomColors.joystickKnob.withOpacity(0.8),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            widget.holdSteering ? 
              Icons.lock_outline : 
              Icons.lock_open,
            color: widget.holdSteering ? 
              Colors.white : 
              CustomColors.joystickBase,
            size: 18,
          ),
        ),
      ),
    );
  }

}
